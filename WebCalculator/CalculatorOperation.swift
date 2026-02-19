//
//  CalculatorOperation.swift
//  WebCalculator
//
//  Created by Olya Parsheva on 18.02.2026.
//

import Foundation

struct CalculatorRequest: Codable {
    let op: String
    let a: Float
    let b: Float
    let precision: Int
}

struct CalculatorResponse: Codable {
    let ok: Bool
    let result: Float?
    let error: String?
}
