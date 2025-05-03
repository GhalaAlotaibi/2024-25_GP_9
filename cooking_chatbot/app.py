from flask import Flask, request, jsonify
from flask_cors import CORS
from solu import get_answer

app = Flask(__name__)
CORS(app)  # Enable for Flutter app

@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json()
    query = data.get('query', '')
    response = get_answer(query)
    return jsonify({"response": response})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)