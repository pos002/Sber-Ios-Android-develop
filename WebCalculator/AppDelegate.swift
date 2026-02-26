import UIKit
import SwiftData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    // Создаём контейнер SwiftData
    lazy var modelContainer: ModelContainer = {
        let schema = Schema([CalculationHistory.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [configuration])
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let calculatorVC = CalculatorViewController()
        calculatorVC.modelContext = modelContainer.mainContext
        
        let navController = UINavigationController(rootViewController: calculatorVC)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        return true
    }
}
