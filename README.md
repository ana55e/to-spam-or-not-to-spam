# to-spam-or-not-to-spam
code Swift qui utilise BERT via un serveur Python (avec Hugging Face) et Mistral via Ollama pour la classification de texte en français


### Explications
1. **Serveur Python (BERT)** :
   * Utilise le pipeline `text-classification` de Hugging Face avec le modèle `camembert-base` (adapté au français). 
   * Fournit une API à l'adresse `http://localhost:5000/classify_bert` . 

2. **Classification avec Mistral (Ollama)** :
   * Envoie un prompt structuré pour demander une classification en français. 
   * Utilise l'API de Ollama (`http://localhost:11434/api/generate`) . 

3. **Gestion des erreurs** :
   * Gère les erreurs de connexion, de réponse invalide et de données corrompues. 
   * Utilise `async/await` pour des appels asynchrones non bloquants. 

4. **Résultats** :
   * Retourne un dictionnaire avec les résultats de BERT et Mistral. 



### Exemple de sortie
```plaintext
Entrez un texte à classifier (spam/non-spam) :
Gagnez 1000€ en 24h ! Cliquez ici.
Classification en cours...
Résultats de la classification :
["bert": "spam", "mistral": "spam"]
```



### Prérequis
1. **Ollama** : Assurez-vous que Mistral est configuré et accessible via `http://localhost:11434`.
2. **Serveur Python** : Lancez le script `server_bert.py` avant d'exécuter le code Swift.
3. **Librairies Python** : Installez les dépendances avec `pip install flask transformers`.
