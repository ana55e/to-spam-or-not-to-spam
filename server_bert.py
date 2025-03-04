from flask import Flask, request, jsonify
from transformers import pipeline

app = Flask(__name__)

# Chargez le modèle CamemBERT pré-entraîné pour la classification (adapté au français)
classifier = pipeline(
    "text-classification",
    model="camembert-base",
    return_all_scores=True
)

@app.route('/classify_bert', methods=['POST'])
def classify():
    data = request.json
    text = data.get('text', '')
    result = classifier(text)
    # Filtrer les résultats pour spam/non-spam
    filtered = [
        {"label": score['label'], "score": score['score']}
        for score in result[0]
        if score['label'] in ["spam", "not_spam"]
    ]
    return jsonify(filtered)

if __name__ == '__main__':
    app.run(port=5000)
