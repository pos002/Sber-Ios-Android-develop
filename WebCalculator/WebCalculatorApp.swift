//
//  WebCalculatorApp.swift
//  WebCalculator
//
//  Created by Olya Parsheva on 18.02.2026.
//

import SwiftUI
import SwiftData

@main
struct WebCalculatorApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CalculationHistory.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
