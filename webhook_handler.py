from flask import Flask, request

app = Flask(__name__)
@app.route('/webhook', methods=['POST'])
def webhook():
    # Here you can process the data received in the POST request
    data = request.get_json()
    print('Received data: ', data)
    return 'Success', 200
if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=True)