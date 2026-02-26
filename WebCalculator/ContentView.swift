//
//  ContentView.swift
//  WebCalculator
//
//  Created by Olya Parsheva on 18.02.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel = CalculatorViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var showHistory = false
    
    let buttons: [[String]] = [
        ["C", "^", "%", "/"],
        ["7", "8", "9", "*"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["","0", ".", "="]
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            // Верхняя панель
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
            
            // Клавиатура (вынесена в отдельную вью)
            CalculatorKeyboard(buttons: buttons, action: handleButtonTap)
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
    
    // MARK: - Обработка нажатий
    private func handleButtonTap(_ title: String) {
        Task {
            switch title {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                viewModel.inputDigit(Int(title)!)
            case ".":
                viewModel.inputDecimal()
            case "C":
                viewModel.clear()
            case "=":
                await viewModel.calculate()
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
            case "+": await viewModel.performOperation("add")
            case "-": await viewModel.performOperation("sub")
            case "*": await viewModel.performOperation("mul")
            case "/": await viewModel.performOperation("div")
            case "%": await viewModel.performOperation("mod")
            case "^": await viewModel.performOperation("pow")
            case ".", ",": viewModel.inputDecimal()
            case "=", "\r": await viewModel.calculate()
            case "c", "escape": viewModel.clear()
            case "h": showHistory = true
            default: break
            }
        }
    }
}

// MARK: - Вынесенная клавиатура
struct CalculatorKeyboard: View {
    let buttons: [[String]]
    let action: (String) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<buttons.count, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(0..<buttons[row].count, id: \.self) { col in
                        let title = buttons[row][col]
                        Group {
                            if !title.isEmpty {
                                CalculatorButton(title: title) {
                                    action(title)
                                }
                            } else {
                                Color(.clear)
                            }
                        } .frame(width: 70, height: 70)
                    }
                }
            }
        }
    }
}

// MARK: - Кнопка калькулятора
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
        case "C", "^", "%": return Color.orange.opacity(0.8)
        case "=", "+", "-", "*", "/": return Color.orange
        case "0": return Color.gray.opacity(0.3)
        default: return Color.gray.opacity(0.5)
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
