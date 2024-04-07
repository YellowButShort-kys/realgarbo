from flask import Flask, request
#VQ9fzeRfrjQCudkl7jzZLvkF3kwVNw7ACGCA1jzdvDeoFk2H6SDQoGItFnqORZ2E
app = Flask(__name__)
@app.route('/lava', methods=['POST'])
def webhook():
    data = request.get_json()
    print('Received data: ', data)
    return 'Success', 200
if __name__ == '__main__':
    app.run(host="158.160.134.126", debug=True)