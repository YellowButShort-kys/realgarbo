headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer t1.9euelZqQmJCTiZOUjMfJmo6Km5uNme3rnpWajoyKm4uVi5bOzsycjI_Jy5rl8_cObC9P-e8gEFMo_d3z904aLU_57yAQUyj9zef1656VmsuNmsqKjcuQkJGNlMuXz4-W7_zF656VmsuNmsqKjcuQkJGNlMuXz4-W.MGp8zKERv4mQNyY_z9ZnmJKZO6BbTJU27SulVUSfLdrWm2aZYkLBopaT977gXbfpSTJ6IZda-XzczwXecWOaCw"
}


from flask import Flask, request, jsonify
import requests
#VQ9fzeRfrjQCudkl7jzZLvkF3kwVNw7ACGCA1jzdvDeoFk2H6SDQoGItFnqORZ2E
app = Flask(__name__)
@app.route('/Translator', methods=['POST'])
def webhook():
    data = request.get_json()
    print('Received data: ', data)
    r = requests.post("https://translate.api.cloud.yandex.net/translate/v2/translate", data={
        "sourceLanguageCode": "ru",
        "targetLanguageCode": "en",
        "texts": [str],
        "folderId": "b1g15f5au931q1a4dqve",
    }, headers=headers).json()["translations"][0]["text"]
    return jsonify()
if __name__ == '__main__':
    app.run(host="158.160.153.133:5000", debug=True)