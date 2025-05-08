from flask import Flask, request, jsonify
from flask_cors import CORS
from cooking_chatbot.solu import get_answer
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json()
    query = data.get('query', '')
    response = get_answer(query)
    return jsonify({"response": response})

# Only run the dev server if this script is run directly (i.e. not with gunicorn)
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
