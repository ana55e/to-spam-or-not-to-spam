import Foundation

// MARK: - Erreurs personnalisées
enum ClassificationError: Error {
    case invalidResponse
    case serverUnavailable
    case invalidData
}

// MARK: - Classification avec BERT (via serveur Python)
func classifyWithBERT(_ text: String) async throws -> String {
    let url = URL(string: "http://localhost:5000/classify_bert")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let body = ["text": text]
    request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
    
    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ClassificationError.serverUnavailable
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
              let firstResult = json.first,
              let label = firstResult["label"] as? String else {
            throw ClassificationError.invalidData
        }
        
        return label
    } catch {
        throw error
    }
}

// MARK: - Classification avec Mistral (via Ollama)
func classifyWithMistral(_ text: String) async throws -> String {
    let url = URL(string: "http://localhost:11434/api/generate")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let prompt = """
    Classez le texte suivant comme spam ou non-spam : \(text)
    Réponse : Spam ou Non-spam.
    """
    
    let body: [String: Any] = [
        "model": "mistral",
        "prompt": prompt,
        "max_tokens": 50,
        "temperature": 0.0
    ]
    request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
    
    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ClassificationError.serverUnavailable
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let result = json["response"] as? String else {
            throw ClassificationError.invalidData
        }
        
        return result.trimmingCharacters(in: .whitespaces).lowercased()
    } catch {
        throw error
    }
}

// MARK: - Fonction principale
@main
struct TextClassifier {
    static func main() async {
        print("Entrez un texte à classifier (spam/non-spam) :")
        guard let inputText = readLine() else {
            print("Erreur lors de la lecture du texte.")
            return
        }
        
        print("Classification en cours...")
        
        let results: [String: String] = await withThrowingTaskGroup(of: (String, String).self) { group in
            var dict = [String: String]()
            
            group.addTask {
                (try await classifyWithBERT(inputText), "bert")
            }
            
            group.addTask {
                (try await classifyWithMistral(inputText), "mistral")
            }
            
            do {
                for try await (result, model) in group {
                    dict[model] = result
                }
            } catch {
                print("Une erreur est survenue : \(error)")
            }
            
            return dict
        }
        
        print("\nRésultats de la classification :")
        print(results)
    }
}
