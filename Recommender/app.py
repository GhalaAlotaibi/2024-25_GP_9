from flask import Flask, request, jsonify
from Recommender.recTest import recommend_food_trucks

app = Flask(__name__)

# Define the home route for the root URL
@app.route("/", methods=['GET'])
def home():
    return "hello world :)"

# Define the recommend route for your recommendation API
@app.route("/recommend", methods=['GET'])
def recommend():
    # Get the user_id from the query parameters
    user_id = request.args.get('user_id')
    lat = float(request.args.get('lat'))
    lon = float(request.args.get('lon'))

    # Call your recommendation function (you should have your logic in recommend_food_trucks)
    recommended_ids = recommend_food_trucks(user_id, (lat, lon))

    # Return the recommended food truck IDs as JSON
    return jsonify({"recommended_food_trucks": recommended_ids})

# Flask app running with the correct port configuration
import os

if __name__ == '__main__':
    # Use the environment variable PORT for deployment (Render or other platforms)
    port = int(os.environ.get('PORT', 10000))
    app.run(host='0.0.0.0', port=port)
