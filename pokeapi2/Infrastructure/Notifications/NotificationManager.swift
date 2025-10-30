//
//  NotificationManager.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//
import UserNotifications
import UIKit

/// Manages local notifications for the app
final class NotificationManager: NSObject {
    static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    // MARK: - Permission
    
    /// Requests notification permission from the user
    func requestPermission() async throws -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            
            if granted {
                AppLogger.success("Notification permission granted", category: .notification)
            } else {
                AppLogger.warning("Notification permission denied", category: .notification)
            }
            
            return granted
        } catch {
            AppLogger.error("Error requesting notification permission", error: error, category: .notification)
            throw error
        }
    }
    
    /// Checks current notification permission status
    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Send Notifications
    
    /// Sends a local notification about new Pokemon
    /// - Parameter count: Number of new Pokemon fetched
    func sendPokemonUpdateNotification(count: Int) async throws {
        let content = UNMutableNotificationContent()
        content.title = "New Pokemon Available!"
        content.body = "\(count) new Pokemon have been added to your Pokédex."
        content.sound = .default
        content.badge = NSNumber(value: count)
        
        // Add custom data
        content.userInfo = ["type": "pokemon_update", "count": count]
        
        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "pokemon_update_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            AppLogger.success("Notification scheduled successfully", category: .notification)
        } catch {
            AppLogger.error("Error scheduling notification", error: error, category: .notification)
            throw error
        }
    }
    
    /// Removes all delivered notifications
    func clearAllNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    /// Removes pending notification requests
    func clearPendingNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    /// Called when notification is received while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Called when user taps on notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let type = userInfo["type"] as? String, type == "pokemon_update" {
            AppLogger.info("User tapped on Pokemon update notification", category: .notification)
            // You can handle navigation here if needed
            NotificationCenter.default.post(
                name: NSNotification.Name("RefreshPokemonList"),
                object: nil
            )
        }
        
        completionHandler()
    }
}
