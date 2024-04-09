headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer t1.9euelZqYipaRiseTmIzNypCbk5CJmO3rnpWajoyKm4uVi5bOzsycjI_Jy5rl9PdFTSlP-e8IFkmo3fT3BXwmT_nvCBZJqM3n9euelZqPx4-Ukp2Mk5GbmZjHy8nKnO_8xeuelZqPx4-Ukp2Mk5GbmZjHy8nKnA.iLwxhQcCvCbVTzenxsxSFgD1J9IPeQowNR9QuT2oCCicpE7Gizk4Lqjsa4OHmQ1TONefteM48xiuIleET5mSAg"
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