//
//  Persistence.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//

import CoreData

/// Manages Core Data stack with proper error handling
/// Singleton pattern for app-wide access
final class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PokeApp")
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // In production, you should handle this error appropriately
                // For now, we'll log it
                AppLogger.error("Core Data Error: \(error), \(error.userInfo)", category: .storage)
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // Automatic merging of changes
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Background Context
    
    /// Creates a new background context for performing operations off the main thread
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    // MARK: - Save Context
    
    /// Saves changes in the given context
    func saveContext(_ context: NSManagedObjectContext) async throws {
        guard context.hasChanges else { return }
        
        do {
            try await context.perform {
                try context.save()
            }
        } catch {
            throw StorageError.saveFailed(error)
        }
    }
    
    /// Saves the main view context
    func saveViewContext() async throws {
        try await saveContext(viewContext)
    }
    
    // MARK: - Testing Support
    
    #if DEBUG
    /// Creates an in-memory persistent container for testing
    static func inMemoryContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "PokeApp")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        
        return container
    }
    #endif
}
