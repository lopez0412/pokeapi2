//
//  pokeapi2App.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//

import SwiftUI

@main
struct pokeapi2App: App {
    let persistenceController = CoreDataStack.shared
    
    // App coordinator
    let appCoordinator = AppCoordinator()
    
    // Background and notification managers
    let backgroundTaskManager = BackgroundTaskManager.shared
    let notificationManager = NotificationManager.shared
    
    init() {
        // Register background tasks
        backgroundTaskManager.registerBackgroundTasks()
        
        // Request notification permission
        Task {
            _ = try? await NotificationManager.shared.requestPermission()
        }
        
        // Schedule first background fetch
        backgroundTaskManager.scheduleBackgroundFetch()
        
        AppLogger.success("App initialized with background fetch support", category: .general)
    }
    
    var body: some Scene {
        WindowGroup {
            appCoordinator.start()
        }
    }
}
