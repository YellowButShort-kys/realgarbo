headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer t1.9euelZrGnpzPzZyZkcybi5CKjJrNye3rnpWajoyKm4uVi5bOzsycjI_Jy5rl8_dQLSFP-e80ewYt_N3z9xBcHk_57zR7Bi38zef1656VmpSclpXOmJLPjMyLzJuPlcyV7_zF656VmpSclpXOmJLPjMyLzJuPlcyV.eqBHjZUczhBLYNenPmMHtrrRS6YiPxs9fiRZ4i99SKbxQCG4dzKKtkahRzJvQ4f1iV69woZMdqgVAyrtGNQBDw"
}


from flask import Flask, request, jsonify
import requests
#VQ9fzeRfrjQCudkl7jzZLvkF3kwVNw7ACGCA1jzdvDeoFk2H6SDQoGItFnqORZ2E
app = Flask(__name__)
@app.route('/Translator', methods=['POST'])
def webhook():
    data = request.get_json()
    print('Received data: ', data)
    r = requests.post("https://translate.api.cloud.yandex.net/translate/v2/translate", json={r"sourceLanguageCode": r"ru",r"targetLanguageCode": r"en",r"texts": [data["ToTranslate"]],r"folderId": r"b1g15f5au931q1a4dqve"}, headers=headers).json()["translations"][0]["text"]
    return jsonify({"Translated": r})
if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=True)