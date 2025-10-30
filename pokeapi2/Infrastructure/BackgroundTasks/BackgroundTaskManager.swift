//
//  BackgroundTaskManager.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//
import BackgroundTasks
import UIKit

/// Manages background fetch tasks for updating Pokemon data
final class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    // Background task identifier - must match Info.plist
    private let taskIdentifier = "com.pokeapi2.fetchPokemon"
    
    private let backgroundFetchUseCase: BackgroundFetchUseCase
    private let notificationManager: NotificationManager
    
    private init() {
        let networkClient = NetworkClient()
        let pokemonRepository = PokemonRepository(networkClient: networkClient)
        let localRepository = LocalStorageRepository()
        
        self.backgroundFetchUseCase = BackgroundFetchUseCase(
            pokemonRepository: pokemonRepository,
            localRepository: localRepository
        )
        self.notificationManager = NotificationManager.shared
    }
    
    // MARK: - Registration
    
    /// Registers the background task handler
    /// Call this in AppDelegate or App init
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskIdentifier,
            using: nil
        ) { task in
            self.handleBackgroundFetch(task: task as! BGAppRefreshTask)
        }
        
        AppLogger.info("Background task registered: \(taskIdentifier)", category: .background)
    }
    
    // MARK: - Scheduling
    
    /// Schedules the next background fetch
    func scheduleBackgroundFetch() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        
        // Schedule for 15 minutes from now (minimum is 15 min)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            AppLogger.success("Background fetch scheduled for \(request.earliestBeginDate!)", category: .background)
        } catch {
            AppLogger.error("Could not schedule background fetch", error: error, category: .background)
        }
    }
    
    /// Cancels all pending background tasks
    func cancelAllBackgroundTasks() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: taskIdentifier)
        AppLogger.warning("Background tasks cancelled", category: .background)
    }
    
    // MARK: - Handling
    
    private func handleBackgroundFetch(task: BGAppRefreshTask) {
        AppLogger.info("Background fetch started", category: .background)
        
        // Schedule next fetch
        scheduleBackgroundFetch()
        
        // Set expiration handler
        task.expirationHandler = {
            AppLogger.warning("Background task expired", category: .background)
            task.setTaskCompleted(success: false)
        }
        
        // Perform the fetch
        Task {
            do {
                let newPokemon = try await backgroundFetchUseCase.execute()
                
                AppLogger.success("Background fetch completed: \(newPokemon.count) new Pokemon", category: .background)
                
                // Send notification
                try await notificationManager.sendPokemonUpdateNotification(
                    count: newPokemon.count
                )
                
                // Notify app to refresh UI if open
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("BackgroundFetchCompleted"),
                        object: nil,
                        userInfo: ["count": newPokemon.count]
                    )
                }
                
                task.setTaskCompleted(success: true)
                
            } catch {
                AppLogger.error("Background fetch failed", error: error, category: .background)
                task.setTaskCompleted(success: false)
            }
        }
    }
    
    // MARK: - Manual Trigger (for testing)
    
    /// Manually triggers background fetch for testing
    /// Only works in development/simulator
    func triggerBackgroundFetchManually() {
        Task {
            do {
                AppLogger.debug("Manual background fetch triggered", category: .background)
                let newPokemon = try await backgroundFetchUseCase.execute()
                
                AppLogger.success("Manual fetch completed: \(newPokemon.count) new Pokemon", category: .background)
                
                try await notificationManager.sendPokemonUpdateNotification(
                    count: newPokemon.count
                )
                
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("BackgroundFetchCompleted"),
                        object: nil,
                        userInfo: ["count": newPokemon.count]
                    )
                }
            } catch {
                AppLogger.error("Manual fetch failed", error: error, category: .background)
            }
        }
    }
}
