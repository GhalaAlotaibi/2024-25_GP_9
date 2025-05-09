from flask import Flask, request, jsonify
from flask_cors import CORS
try:
    from cooking_chatbot.solu import get_answer
except Exception as e:
    print(f"❌ Failed to import get_answer: {e}")

import os

app = Flask(__name__)
# Replace CORS(app) with this:
 
@app.route('/', methods=['GET'])
def home():
    return jsonify({
        "status": "running",
        "usage": "Send POST requests to /chat",
        "example": {"query": "Your cooking question in Arabic"}
    })

@app.route('/chat', methods=['POST'])
def chat():
    try:
        data = request.get_json()
        query = data.get('query', '')
        response = get_answer(query)
        return jsonify({"response": response})
    except Exception as e:
        print(f"🔥 ERROR in /chat route: {e}")
        return jsonify({"error": "Internal Server Error"}), 500

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 10000))
    print(f"🔵 Flask server running on port {port}")  
    app.run(host="0.0.0.0", port=port)
