//
//  CalculatorViewModel.swift
//  WebCalculator
//
//  Created by Olya Parsheva on 18.02.2026.
//

// свойства с оберткой @Published автоматически уведомляет View об изменениях

import Foundation
import Combine
import SwiftData

class CalculatorViewModel: ObservableObject {
    @Published var display: String = "0" // что видно на экране
    @Published var firstOperand: Float? // первый введенный операнд
    @Published var operation: String? // выбранная операция
    @Published var waitingForSecondOperand: Bool = false // флаг состояния
    @Published var errorMessage: String? // сообщение об ошибке
    @Published var showHistory: Bool = false
    
    private let networkService = NetworkService.shared
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func inputDigit(_ digit: Int) {
        if errorMessage != nil {
            errorMessage = nil
            display = "\(digit)"
            return
        }
        
        if waitingForSecondOperand {
            display = "\(digit)"
            waitingForSecondOperand = false
        } else {
            if display == "0" {
                display = "\(digit)"
            } else {
                display += "\(digit)"
            }
        }
    }
    
    func inputDecimal() {
        if waitingForSecondOperand {
            display = "0."
            waitingForSecondOperand = false
            return
        }
        
        if !display.contains(".") {
            display += "."
        }
    }
    
    // асинхронные вычисления
    func performOperation(_ op: String) async {
        if errorMessage != nil {
            errorMessage = nil
        }
        
        let currentOperand = Float(display) ?? 0
        
        if let first = firstOperand, let operation = operation {
            do {
                let result = try await networkService.calculate(
                    operation: operation,
                    a: first,
                    b: currentOperand
                )
                display = formatResult(result)
                firstOperand = result
            } catch {
                handleError(error)
                return
            }
        } else {
            firstOperand = currentOperand
        }
        
        self.operation = op
        waitingForSecondOperand = true
    }
    
    func calculate() async {
        guard let first = firstOperand, let operation = operation else {
            return
        }
        
        let second = Float(display) ?? 0
        
        do {
            let result = try await networkService.calculate(
                operation: operation,
                a: first,
                b: second
            )
            display = formatResult(result)
            
            // Сохраняем в историю
            saveToHistory(operation: operation, a: first, b: second, result: result)
            
            firstOperand = nil
            self.operation = nil
            waitingForSecondOperand = true
        } catch {
            handleError(error)
        }
    }
    
    func clear() {
        display = "0"
        firstOperand = nil
        operation = nil
        waitingForSecondOperand = false
        errorMessage = nil
    }
    
    private func formatResult(_ value: Float) -> String {
        if value == Float(Int(value)) {
            return "\(Int(value))"
        } else {
            return String(format: "%.2f", value)
        }
    }
    
    private func handleError(_ error: Error) {
        print("Ошибка: \(error.localizedDescription)")
        
        if let networkError = error as? NetworkError {
            switch networkError {
            case .noConnection, .invalidURL, .invalidResponse, .serverError:
                errorMessage = "Сервер недоступен"
                display = "Error"
            case .calculationError(let message):
                errorMessage = message
                display = "Error"
            }
        } else {
            errorMessage = "Ошибка: \(error.localizedDescription)"
            display = "Error"
        }
    }
    
    // MARK: - История вычислений
    private func saveToHistory(operation: String, a: Float, b: Float, result: Float) {
        guard let context = modelContext else {
            print("ModelContext не инициализирован")
            return
        }
        
        let historyItem = CalculationHistory(
            operation: getOperationSymbol(operation),
            operandA: a,
            operandB: b,
            result: result
        )
        
        context.insert(historyItem)
        
        do {
            try context.save() // сохраняем в историю
            print("Сохранено в историю: \(a) \(getOperationSymbol(operation)) \(b) = \(result)")
        } catch {
            print("Ошибка сохранения в историю: \(error)")
        }
    }
    
    private func getOperationSymbol(_ op: String) -> String {
        switch op {
        case "add": return "+"
        case "sub": return "-"
        case "mul": return "*"
        case "div": return "/"
        case "mod": return "%"
        case "pow": return "^"
        default: return op
        }
    }
    
    func fetchHistory() -> [CalculationHistory] {
        guard let context = modelContext else {
            return []
        }
        
        let descriptor = FetchDescriptor<CalculationHistory>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Ошибка получения истории: \(error)")
            return []
        }
    }
    
    func clearHistory() {
        guard let context = modelContext else {
            return
        }
        
        do {
            let descriptor = FetchDescriptor<CalculationHistory>()
            let items = try context.fetch(descriptor)
            for item in items {
                context.delete(item)
            }
            try context.save()
            print("История очищена")
        } catch {
            print("Ошибка очистки истории: \(error)")
        }
    }
}
