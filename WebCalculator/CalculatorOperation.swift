//
//  CalculatorOperation.swift
//  WebCalculator
//
//  Created by Olya Parsheva on 18.02.2026.
//

// эти структуры преобразуются в json для отправки на сервер
// codable - протокол для сериализации
import Foundation

struct CalculatorRequest: Codable {
    let op: String // название операции
    let a: Float // первый операнд
    let b: Float // второй операнд
    let precision: Int // точность округления
}

struct CalculatorResponse: Codable {
    let ok: Bool // флаг успеха
    let result: Float? // результат (nil, если ошибка)
    let error: String? // сообщение об ошибке
}
