//
//  CalculationHistory.swift
//  WebCalculator
//
//  Created by Olya Parsheva on 19.02.2026.
//

import Foundation
import SwiftData

@Model
class CalculationHistory {
    var id: UUID
    var operation: String
    var operandA: Float
    var operandB: Float
    var result: Float
    var timestamp: Date
    
    init(operation: String, operandA: Float, operandB: Float, result: Float) {
        self.id = UUID()
        self.operation = operation
        self.operandA = operandA
        self.operandB = operandB
        self.result = result
        self.timestamp = Date()
    }
}
