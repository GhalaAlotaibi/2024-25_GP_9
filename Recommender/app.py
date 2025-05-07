from flask import Flask, request, jsonify
from Recommender.recTest import recommend_food_trucks
#change number 1 => was :from recTest import recommend_food_trucks
 

app = Flask(__name__)

@app.route('/recommend', methods=['GET'])  
@app.route("/")
def home():
    return "hello world :)"

def recommend():
    # Get the user_id from the query parameters
    user_id = request.args.get('user_id')
    lat = float(request.args.get('lat'))
    lon = float(request.args.get('lon'))

    # Call your recommendation function
    recommended_ids = recommend_food_trucks(user_id, (lat, lon))

    # Return the recommended food truck IDs as JSON
    return jsonify({"recommended_food_trucks": recommended_ids})
#change 4=> commented the two lines below
#if __name__ == "__main__":
 #   app.run(host="0.0.0.0", port=5000)

#nd added these lines 
import os

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 10000))
    app.run(host='0.0.0.0', port=port)
#flutter run -d 95d3370af
