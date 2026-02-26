//
//  HistoryViewController.swift
//  WebCalculator
//
//  Created by Olya Parsheva on 26.02.2026.
//

import UIKit
import SwiftData

class HistoryViewController: UITableViewController {
    
    var modelContext: ModelContext?
    private var history: [CalculationHistory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "История вычислений"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Очистить", style: .plain, target: self, action: #selector(clearHistory))
        fetchHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchHistory()
    }
    
    private func fetchHistory() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<CalculationHistory>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        history = (try? context.fetch(descriptor)) ?? []
        tableView.reloadData()
    }
    
    @objc private func clearHistory() {
        guard let context = modelContext else { return }
        for item in history {
            context.delete(item)
        }
        try? context.save()
        fetchHistory()
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = history[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        let dateStr = dateFormatter.string(from: item.timestamp)
        let expr = "\(formatNumber(item.operandA)) \(item.operation) \(formatNumber(item.operandB)) = \(formatNumber(item.result))"
        cell.textLabel?.text = "\(dateStr): \(expr)"
        return cell
    }
    
    private func formatNumber(_ value: Float) -> String {
        if value == Float(Int(value)) {
            return "\(Int(value))"
        } else {
            return String(format: "%.2f", value)
        }
    }
}
