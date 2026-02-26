//
//  NetworkService.swift
//  WebCalculator
//
//  Created by Olya Parsheva on 18.02.2026.
//

import Foundation

class NetworkService {
    static let shared = NetworkService() // единственный экземпляр
    private let baseURL = "http://185.200.179.100:8083/api/calc" // приватный нициализатор
    
    private init() {}
    
    func calculate(operation: String, a: Float, b: Float, precision: Int = 2) async throws -> Float {
        let request = CalculatorRequest(op: operation, a: a, b: b, precision: precision)
        
        guard let url = URL(string: baseURL) else {
            throw NetworkError.invalidURL
        }
        // URLRequest конфигурация
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST" // отправляем данные на сервер
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") // говорим, что отправляем JSON
        urlRequest.httpBody = try JSONEncoder().encode(request) // данные в JSON формате
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(CalculatorResponse.self, from: data)
        
        guard let calcResult = result.result else {
            throw NetworkError.calculationError(message: result.error ?? "Unknown error")
        }
        
        return calcResult
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case calculationError(message: String)
    case noConnection
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .invalidResponse:
            return "Неверный ответ сервера"
        case .serverError(let statusCode):
            return "Ошибка сервера: \(statusCode)"
        case .calculationError(let message):
            return message
        case .noConnection:
            return "Сервер недоступен"
        }
    }
}
