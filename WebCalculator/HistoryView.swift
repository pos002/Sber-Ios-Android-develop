//
//  HistoryView.swift
//  WebCalculator
//
//  Created by Olya Parsheva on 19.02.2026.
//

// @Query - автоматически загружает данные из SwiftData, сортирует по времени и обновляется при изменениях в БД

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CalculationHistory.timestamp, order: .reverse) private var history: [CalculationHistory]
    
    var body: some View {
        NavigationStack {
            Group {
                if history.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "clock.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("История пуста")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Выполните вычисления, чтобы увидеть историю")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else {
                    // табличное представление
                    Table(history) {
                        TableColumn("Время") { item in
                            Text(item.timestamp, style: .time)
                                .foregroundColor(.secondary)
                        }
                        .width(100)
                        
                        TableColumn("Дата") { item in
                            Text(item.timestamp, style: .date)
                                .foregroundColor(.secondary)
                        }
                        .width(120)
                        
                        TableColumn("Выражение") { item in
                            Text("\(formatNumber(item.operandA)) \(item.operation) \(formatNumber(item.operandB))")
                        }
                        .width(200)
                        
                        TableColumn("Результат") { item in
                            Text(formatNumber(item.result))
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        .width(150)
                    }
                }
            }
            .navigationTitle("История вычислений")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: clearHistory) {
                        Label("Очистить", systemImage: "trash")
                    }
                    .disabled(history.isEmpty)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .keyboardShortcut(.escape, modifiers: [])
                }
            }
        }
        .frame(minWidth: 700, minHeight: 400)
    }
    
    private func formatNumber(_ value: Float) -> String {
        if value == Float(Int(value)) {
            return "\(Int(value))"
        } else {
            return String(format: "%.2f", value)
        }
    }
    
    private func clearHistory() {
        for item in history {
            modelContext.delete(item)
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: CalculationHistory.self, inMemory: true)
}
