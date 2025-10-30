//
//  LocalStorageRepository.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//
import CoreData

/// Concrete implementation of LocalStorageRepositoryProtocol
/// Handles all Core Data operations for Pokemon storage
final class LocalStorageRepository: LocalStorageRepositoryProtocol {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Save Operations
    
    /// Saves Pokemon to local storage
    func savePokemon(_ pokemon: [Pokemon]) async throws {
        let context = coreDataStack.newBackgroundContext()
        
        try await context.perform {
            // Delete existing Pokemon to avoid duplicates
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = PokemonEntityModel.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
            
            // Create new entities
            pokemon.forEach { pokemon in
                _ = PokemonEntityModel.create(from: pokemon, context: context)
            }
            
            // Save context
            if context.hasChanges {
                try context.save()
                AppLogger.logStorage(operation: "Saved \(pokemon.count) Pokemon", success: true)
            }
        }
    }
    
    // MARK: - Fetch Operations
    
    /// Retrieves all Pokemon from local storage
    func fetchAllPokemon() async throws -> [Pokemon] {
        let context = coreDataStack.viewContext
        
        return try await context.perform {
            let fetchRequest: NSFetchRequest<PokemonEntityModel> = PokemonEntityModel.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            
            do {
                let entities = try context.fetch(fetchRequest)
                return entities.map { $0.toDomain() }
            } catch {
                throw StorageError.fetchFailed(error)
            }
        }
    }
    
    /// Searches for Pokemon matching a query
    func searchPokemon(query: String) async throws -> [Pokemon] {
        guard !query.isEmpty else {
            return try await fetchAllPokemon()
        }
        
        let context = coreDataStack.viewContext
        
        return try await context.perform {
            let fetchRequest: NSFetchRequest<PokemonEntityModel> = PokemonEntityModel.fetchRequest()
            
            // Search by name or ID
            if let searchId = Int32(query) {
                fetchRequest.predicate = NSPredicate(
                    format: "name CONTAINS[cd] %@ OR id == %d",
                    query, searchId
                )
            } else {
                fetchRequest.predicate = NSPredicate(
                    format: "name CONTAINS[cd] %@",
                    query
                )
            }
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            
            do {
                let entities = try context.fetch(fetchRequest)
                return entities.map { $0.toDomain() }
            } catch {
                throw StorageError.fetchFailed(error)
            }
        }
    }
    
    // MARK: - Delete Operations
    
    /// Deletes all Pokemon from local storage
    func deleteAllPokemon() async throws {
        let context = coreDataStack.newBackgroundContext()
        
        try await context.perform {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = PokemonEntityModel.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                throw StorageError.deleteFailed(error)
            }
        }
    }
    
    // MARK: - Utility
    
    /// Checks if local storage contains any Pokemon data
    func hasStoredData() async -> Bool {
        let context = coreDataStack.viewContext
        
        return await context.perform {
            let fetchRequest: NSFetchRequest<PokemonEntityModel> = PokemonEntityModel.fetchRequest()
            fetchRequest.fetchLimit = 1
            
            do {
                let count = try context.count(for: fetchRequest)
                return count > 0
            } catch {
                return false
            }
        }
    }
}
