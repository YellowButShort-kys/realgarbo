from flask import Flask, request, jsonify
import requests
app = Flask(__name__)
@app.route('/YTShorts_GetSubreddit', methods=['GET'])
def webhook():
    data = request.get_json()
    if 
    
    
if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=True)