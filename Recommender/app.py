from flask import Flask, request, jsonify
from recTest import recommend_food_trucks  # Import the recommendation function
 

app = Flask(__name__)

@app.route('/recommend', methods=['GET'])
def recommend():
    # Get the user_id from the query parameters
    user_id = request.args.get('user_id')
    lat = float(request.args.get('lat'))
    lon = float(request.args.get('lon'))

    # Call your recommendation function
    recommended_ids = recommend_food_trucks(user_id, (lat, lon))

    # Return the recommended food truck IDs as JSON
    return jsonify({"recommended_food_trucks": recommended_ids})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)