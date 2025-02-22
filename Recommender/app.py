from flask import Flask, request, jsonify
from recTest import recommend_food_trucks

app = Flask(__name__)

@app.route('/recommend', methods=['POST'])
def get_recommendations():
    data = request.json
    user_id = data.get('user_id')
    user_location = data.get('user_location')
    
    if not user_id or not user_location:
        return jsonify({'error': 'Invalid input data'}), 400
    
    try:
        recommendations = recommend_food_trucks(user_id, tuple(user_location))
        return jsonify(recommendations.to_dict(orient='records'))
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)