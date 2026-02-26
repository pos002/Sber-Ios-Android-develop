//
//  ContentView.swift
//  WebCalculator
//
//  Created by Olya Parsheva on 18.02.2026.
//

// @StateObject - ViewModel живет весь жизненный цикл View
// @Environment - доступ в базе данных (системным объектам)
// @State - простое локальное состояние

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel = CalculatorViewModel() // владеет ViewModel
    @Environment(\.modelContext) private var modelContext // доступ к БД из окружения
    @State private var showHistory = false // локальное состояние
    
    let buttons: [[String]] = [
        ["C", "^", "%", "/"],
        ["7", "8", "9", "*"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", ".", "=", "+"]
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            // Верхняя панель с кнопкой истории
            HStack {
                Text("Web Calculator")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: { showHistory = true }) {
                    Label("История", systemImage: "clock")
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // Дисплей
            VStack(alignment: .trailing, spacing: 5) {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                Text(viewModel.display)
                    .font(.system(size: 48, weight: .light))
                    .frame(height: 80)
                    .padding(.horizontal, 20)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding()
            
            // Кнопки
            VStack(spacing: 8) {
                ForEach(0..<5, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(0..<4, id: \.self) { col in
                            let button = buttons[row][col]
                            CalculatorButton(title: button) {
                                handleButtonTap(button)
                            }
                            .frame(width: 70, height: 70)
                        }
                    }
                }
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 500)
        .background(Color.gray.opacity(0.1))
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
        .onKeyPress { keyPress in
            handleKeyPress(keyPress)
            return .handled
        }
        .focusable()
        .sheet(isPresented: $showHistory) {
            HistoryView()
        }
    }
    
    private func handleButtonTap(_ title: String) {
        Task {
            switch title {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                viewModel.inputDigit(Int(title)!)
            case ".":
                viewModel.inputDecimal()
            case "C":
                viewModel.clear()
            case "=", "+":
                if title == "=" {
                    await viewModel.calculate()
                } else {
                    await viewModel.performOperation("add")
                }
            case "-":
                await viewModel.performOperation("sub")
            case "*":
                await viewModel.performOperation("mul")
            case "/":
                await viewModel.performOperation("div")
            case "%":
                await viewModel.performOperation("mod")
            case "^":
                await viewModel.performOperation("pow")
            default:
                break
            }
        }
    }
    
    private func handleKeyPress(_ keyPress: KeyPress) {
        Task {
            let key = keyPress.characters.lowercased()
            
            if let digit = Int(key) {
                viewModel.inputDigit(digit)
                return
            }
            
            switch key {
            case "+":
                await viewModel.performOperation("add")
            case "-":
                await viewModel.performOperation("sub")
            case "*":
                await viewModel.performOperation("mul")
            case "/":
                await viewModel.performOperation("div")
            case "%":
                await viewModel.performOperation("mod")
            case "^":
                await viewModel.performOperation("pow")
            case ".", ",":
                viewModel.inputDecimal()
            case "=", "\r":
                await viewModel.calculate()
            case "c", "escape":
                viewModel.clear()
            case "h":
                showHistory = true
            default:
                break
            }
        }
    }
}

struct CalculatorButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 24, weight: .medium))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(buttonColor)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    private var buttonColor: Color {
        switch title {
        case "C", "^", "%":
            return Color.orange.opacity(0.8)
        case "=", "+", "-", "*", "/":
            return Color.orange
        case "0":
            return Color.gray.opacity(0.3)
        default:
            return Color.gray.opacity(0.5)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
