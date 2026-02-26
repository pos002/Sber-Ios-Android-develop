//
//  CalculatorViewController.swift
//  WebCalculator
//
//  Created by Olya Parsheva on 26.02.2026.
//

import UIKit
import SwiftData

class CalculatorViewController: UIViewController {
    
    // MARK: - Свойства состояния
    private var display = "0" {
        didSet {
            displayLabel.text = display
        }
    }
    private var firstOperand: Float?
    private var operation: String?
    private var waitingForSecondOperand = false
    private var errorMessage: String? {
        didSet {
            errorLabel.text = errorMessage
            errorLabel.isHidden = (errorMessage == nil)
        }
    }
    
    var modelContext: ModelContext?
    
    // MARK: - UI Элементы
    private let displayLabel = UILabel()
    private let errorLabel = UILabel()
    private let historyButton = UIButton(type: .system)
    
    // Раскладка кнопок
    private let buttons: [[String]] = [
        ["C", "^", "%", "/"],
        ["7", "8", "9", "*"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", ".", "="]
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        title = "Web Calculator"
        setupUI()
    }
    
    private func setupUI() {
        // Дисплей
        displayLabel.font = .systemFont(ofSize: 48, weight: .light)
        displayLabel.textAlignment = .right
        displayLabel.backgroundColor = .systemGray5
        displayLabel.layer.cornerRadius = 10
        displayLabel.layer.masksToBounds = true
        displayLabel.text = "0"
        displayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Метка ошибки
        errorLabel.font = .systemFont(ofSize: 12)
        errorLabel.textColor = .red
        errorLabel.textAlignment = .right
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Кнопка истории
        historyButton.setTitle("История", for: .normal)
        historyButton.addTarget(self, action: #selector(historyTapped), for: .touchUpInside)
        historyButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Контейнер для кнопок
        let buttonsStack = createButtons()
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(historyButton)
        view.addSubview(errorLabel)
        view.addSubview(displayLabel)
        view.addSubview(buttonsStack)
        
        NSLayoutConstraint.activate([
            historyButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            historyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            errorLabel.topAnchor.constraint(equalTo: historyButton.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            displayLabel.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 4),
            displayLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            displayLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            displayLabel.heightAnchor.constraint(equalToConstant: 80),
            
            buttonsStack.topAnchor.constraint(equalTo: displayLabel.bottomAnchor, constant: 20),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonsStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func createButtons() -> UIStackView {
        let outerStack = UIStackView()
        outerStack.axis = .vertical
        outerStack.spacing = 8
        outerStack.distribution = .fillEqually
        
        for row in buttons {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 8
            rowStack.distribution = .fillEqually
            
            for title in row {
                let button = UIButton(type: .system)
                button.setTitle(title, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = buttonColor(for: title)
                button.layer.cornerRadius = 10
                button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
                rowStack.addArrangedSubview(button)
            }
            outerStack.addArrangedSubview(rowStack)
        }
        return outerStack
    }
    
    private func buttonColor(for title: String) -> UIColor {
        switch title {
        case "C", "^", "%": return .orange.withAlphaComponent(0.8)
        case "=", "+", "-", "*", "/": return .orange
        case "0": return .darkGray.withAlphaComponent(0.3)
        default: return .darkGray
        }
    }
    
    // MARK: - Обработка нажатий
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        
        switch title {
        case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
            inputDigit(Int(title)!)
        case ".":
            inputDecimal()
        case "C":
            clear()
        case "=":
            calculate()
        case "+":
            performOperation("add")
        case "-":
            performOperation("sub")
        case "*":
            performOperation("mul")
        case "/":
            performOperation("div")
        case "%":
            performOperation("mod")
        case "^":
            performOperation("pow")
        default:
            break
        }
    }
    
    @objc private func historyTapped() {
        let historyVC = HistoryViewController()
        historyVC.modelContext = modelContext
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    // MARK: - Логика калькулятора
    private func inputDigit(_ digit: Int) {
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
    
    private func inputDecimal() {
        if waitingForSecondOperand {
            display = "0."
            waitingForSecondOperand = false
            return
        }
        if !display.contains(".") {
            display += "."
        }
    }
    
    private func clear() {
        display = "0"
        firstOperand = nil
        operation = nil
        waitingForSecondOperand = false
        errorMessage = nil
    }
    
    private func performOperation(_ op: String) {
        if errorMessage != nil {
            errorMessage = nil
        }
        
        let current = Float(display) ?? 0
        
        if let first = firstOperand, let currentOp = operation {
            // Выполняем предыдущую операцию
            NetworkService.shared.calculate(operation: currentOp, a: first, b: current) { [weak self] result in
                switch result {
                case .success(let value):
                    self?.display = self?.formatResult(value) ?? ""
                    self?.firstOperand = value
                case .failure(let error):
                    self?.handleError(error)
                    return
                }
            }
        } else {
            firstOperand = current
        }
        
        operation = op
        waitingForSecondOperand = true
    }
    
    private func calculate() {
        guard let first = firstOperand, let op = operation else { return }
        let second = Float(display) ?? 0
        
        NetworkService.shared.calculate(operation: op, a: first, b: second) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                self.display = self.formatResult(value)
                self.saveToHistory(operation: op, a: first, b: second, result: value)
                self.firstOperand = nil
                self.operation = nil
                self.waitingForSecondOperand = true
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    private func formatResult(_ value: Float) -> String {
        if value == Float(Int(value)) {
            return "\(Int(value))"
        } else {
            return String(format: "%.2f", value)
        }
    }
    
    private func handleError(_ error: NetworkError) {
        switch error {
        case .noConnection, .invalidURL, .invalidResponse, .serverError:
            errorMessage = "Сервер недоступен"
            display = "Error"
        case .calculationError(let message):
            errorMessage = message
            display = "Error"
        }
    }
    
    private func saveToHistory(operation: String, a: Float, b: Float, result: Float) {
        guard let context = modelContext else { return }
        let symbol: String
        switch operation {
        case "add": symbol = "+"
        case "sub": symbol = "-"
        case "mul": symbol = "*"
        case "div": symbol = "/"
        case "mod": symbol = "%"
        case "pow": symbol = "^"
        default: symbol = operation
        }
        let item = CalculationHistory(operation: symbol, operandA: a, operandB: b, result: result)
        context.insert(item)
        try? context.save()
    }
}
