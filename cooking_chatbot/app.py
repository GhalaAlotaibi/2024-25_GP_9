from flask import Flask, request, jsonify
from flask_cors import CORS
from cooking_chatbot.solu import get_answer
import os

app = Flask(__name__)
# Replace CORS(app) with this:
CORS(app, resources={
    r"/chat": {
        "origins": ["*"],  # Allow all origins (adjust for production)
        "methods": ["POST"],
        "allow_headers": ["Content-Type"]
    }
})
@app.route("/", methods=['POST'])
def home():
    return "hello world :)"


@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json()
    query = data.get('query', '')
    response = get_answer(query)
    return jsonify({"response": response})

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    print(f"🔵 Flask server running on port {port}")  
    app.run(host="0.0.0.0", port=port)
