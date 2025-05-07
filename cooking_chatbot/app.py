from flask import Flask, request, jsonify
import os
from flask_cors import CORS
from cooking_chatbot.solu import get_answer
# I have the old app.py saved on my notes > May the 7th
app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json()
    query = data.get('query', '')
    response = get_answer(query)
    return jsonify({"response": response})

 
# Render will use gunicorn to run the app, so this is just a fallback
if __name__ == '__main__':
 
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
 