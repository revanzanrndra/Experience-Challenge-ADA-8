//
//  ParkMeterApp.swift
//  ParkMeter
//
//  Created by Tm Revanza Narendra Pradipta on 18/05/25.
//

import SwiftUI
import SwiftData

import UserNotifications

@main
struct ParkMeterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private let modelContainer: ModelContainer
    @StateObject private var viewModel: ParkingViewModel
    
    init() {
        do {
            let config = ModelConfiguration()
            let container = try ModelContainer(for: ParkingLot.self, ParkingSession.self, configurations: config)
            self.modelContainer = container
            self._viewModel = StateObject(wrappedValue: { ParkingViewModel(modelContext: container.mainContext) }())
        } catch {
            print("Failed to initialize ModelContainer: \(error)")
            fatalError("Cannot initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(viewModel)
                .modelContainer(modelContainer)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // Handle notifications in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
