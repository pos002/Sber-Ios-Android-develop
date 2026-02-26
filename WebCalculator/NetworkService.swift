import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case calculationError(message: String)
    case noConnection
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Неверный URL"
        case .invalidResponse: return "Неверный ответ сервера"
        case .serverError(let code): return "Ошибка сервера: \(code)"
        case .calculationError(let msg): return msg
        case .noConnection: return "Сервер недоступен"
        }
    }
}

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "http://185.200.179.100:8083/api/calc"
    private init() {}
    
    func calculate(operation: String, a: Float, b: Float, precision: Int = 2,
                   completion: @escaping (Result<Float, NetworkError>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = CalculatorRequest(op: operation, a: a, b: b, precision: precision)
        request.httpBody = try? JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.noConnection))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(CalculatorResponse.self, from: data)
                if let value = result.result {
                    DispatchQueue.main.async {
                        completion(.success(value))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(.calculationError(message: result.error ?? "Неизвестная ошибка")))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
            }
        }
        task.resume()
    }
}
