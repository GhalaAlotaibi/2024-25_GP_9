from flask import Flask, request, jsonify
from Recommender.recTest import recommend_food_trucks

app = Flask(__name__)
 
@app.route("/", methods=['GET'])
def home():
    return "hello world :)"

@app.route("/recommend", methods=['GET'])
def recommend():

    user_id = request.args.get('user_id')
    lat = float(request.args.get('lat'))
    lon = float(request.args.get('lon'))

    recommended_ids = recommend_food_trucks(user_id, (lat, lon))

    return jsonify({"recommended_food_trucks": recommended_ids})

import os

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 10000))
    app.run(host='0.0.0.0', port=port)


