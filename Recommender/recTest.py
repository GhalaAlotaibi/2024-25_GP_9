import firebase_admin
from firebase_admin import credentials, firestore
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import pandas as pd
from math import radians, sin, cos, sqrt, atan2

# Step 1: Firebase Initialization
cred = credentials.Certificate("cred/trucki-database-firebase-adminsdk-9gf4r-697466e790.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Step 2: Fetch Data from Firestore
def fetch_food_trucks():
    """Fetch all food trucks from the database."""
    food_trucks = db.collection('Food_Truck').stream()
    data = []
    for truck in food_trucks:
        truck_data = truck.to_dict()
        truck_data['foodTruckId'] = truck.id  # Use the document ID as foodTruckId
        # Convert location string to tuple (lat, lon)
        location = list(map(float, truck_data['location'].split(',')))
        truck_data['location'] = location
        data.append(truck_data)
    return pd.DataFrame(data)


def fetch_user_favorites(user_id):
    """Fetch the user's favorite food truck IDs."""
    favorites_docs = db.collection('Favorite').document(user_id).collection('favorites').stream()
    favorite_food_truck_ids = [doc.id for doc in favorites_docs]  # Each document ID is a foodTruckId
    return favorite_food_truck_ids



def fetch_reviews():
    """Fetch all food truck reviews and calculate average ratings."""
    reviews = db.collection('Review').stream()
    data = []
    for review in reviews:
        review_data = review.to_dict()
        review_data['foodTruckId'] = review.get('foodTruckId')  # Ensure foodTruckId exists
        review_data['rating'] = float(review_data['rating'])  # Convert rating to float
        data.append(review_data)
    reviews_df = pd.DataFrame(data)

    # Calculate average rating and count of reviews for each food truck
    rating_summary = reviews_df.groupby('foodTruckId').agg(
        avg_rating=('rating', 'mean'),
        ratings_count=('rating', 'count')
    ).reset_index()
    return rating_summary
# Verify food truck data
food_trucks_df = fetch_food_trucks()
print(food_trucks_df.head())

# Verify review data
reviews_df = fetch_reviews()
print(reviews_df.head())



# Step 3: Combine and Preprocess Data
def preprocess_data(user_id):
    # Fetch food truck data, user favorites, and reviews
    food_trucks_df = fetch_food_trucks()
    user_favorites = fetch_user_favorites(user_id)
    reviews_df = fetch_reviews()

    # Merge reviews with food truck data
    food_trucks_df = food_trucks_df.merge(
        reviews_df, left_on='foodTruckId', right_on='foodTruckId', how='left'
    )

    # Fill missing ratings with default values
    food_trucks_df['avg_rating'].fillna(0, inplace=True)
    food_trucks_df['ratings_count'].fillna(0, inplace=True)

    # Add a combined text column for content similarity
    food_trucks_df['combined_text'] = (
        food_trucks_df['categoryId'] + ' ' +
        food_trucks_df['description'] + ' ' +
        food_trucks_df['name']
    )

    return food_trucks_df, user_favorites

# Step 4: Haversine Formula for Proximity Calculation
def haversine(lat1, lon1, lat2, lon2):
    """Calculate the great-circle distance between two points."""
    R = 6371  # Earth radius in km
    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat/2) * sin(dlat/2) + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon/2) * sin(dlon/2)
    c = 2 * atan2(sqrt(a), sqrt(1-a))
    return R * c

# Step 5: Generate Recommendations
def recommend_food_trucks(user_id, user_location, top_n=5):
    """Generate recommendations for a user."""
    # Preprocess data
    food_trucks_df, user_favorites = preprocess_data(user_id)

    # Vectorize text data for similarity
    tfidf = TfidfVectorizer()
    tfidf_matrix = tfidf.fit_transform(food_trucks_df['combined_text'])
    similarity_matrix = cosine_similarity(tfidf_matrix, tfidf_matrix)

    # Find indices of user's favorite food trucks
    favorite_indices = food_trucks_df[food_trucks_df['foodTruckId'].isin(user_favorites)].index
    print("User Favorites:", user_favorites)
    print("Favorite Indices:", favorite_indices)

    # Handle empty favorites
    if len(favorite_indices) == 0:
        # Default logic: use only ratings and proximity
        similarity_scores = [0] * len(food_trucks_df)
    else:
        similarity_scores = similarity_matrix[favorite_indices].mean(axis=0)

    # Calculate proximity scores
    food_trucks_df['distance'] = food_trucks_df['location'].apply(
        lambda loc: haversine(user_location[0], user_location[1], loc[0], loc[1])
    )
    food_trucks_df['proximity_score'] = 1 / (food_trucks_df['distance'] + 1)  # Inverse distance
    food_trucks_df['normalized_proximity'] = food_trucks_df['proximity_score'] / food_trucks_df['proximity_score'].max()

    # Normalize ratings
    food_trucks_df['normalized_rating'] = food_trucks_df['avg_rating'] / food_trucks_df['avg_rating'].max()

    # Combine all scores with weights
    w1, w2, w3 = 0.5, 0.3, 0.2  # Weights for similarity, rating, and proximity
    food_trucks_df['final_score'] = (
        w1 * similarity_scores +
        w2 * food_trucks_df['normalized_rating'] +
        w3 * food_trucks_df['normalized_proximity']
    )

    # If the user has no favorites, sort by rating and proximity instead
    if len(favorite_indices) == 0:
        food_trucks_df['final_score'] = (
            w2 * food_trucks_df['normalized_rating'] +
            w3 * food_trucks_df['normalized_proximity']
        )

    # Sort and select top N recommendations
    recommendations = food_trucks_df.sort_values(by='final_score', ascending=False).head(top_n)
    return recommendations[['name', 'final_score', 'distance', 'avg_rating', 'ratings_count']]


# Step 6: Example Usage
if __name__ == "__main__":
    user_id = "4QIh8jSpdwdH82nmQRd8WOMKFOj2"  # Replace with the logged-in user's ID
    user_location = (24.70952885058521, 46.770585)  # Example user location (latitude, longitude)

    recommendations = recommend_food_trucks(user_id, user_location)
    print(recommendations)
