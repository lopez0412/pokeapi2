//
//  BackgroundFetchUseCase.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//
import Foundation

/// Use case for background fetch operations
/// Fetches new Pokemon in batches for background updates
final class BackgroundFetchUseCase {
    private let pokemonRepository: PokemonRepositoryProtocol
    private let localRepository: LocalStorageRepositoryProtocol
    private let batchSize: Int = 5
    
    // UserDefaults key for persisting offset
    private let offsetKey = "BackgroundFetch.currentOffset"
    
    private var currentOffset: Int {
        get {
            UserDefaults.standard.integer(forKey: offsetKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: offsetKey)
            AppLogger.debug("Offset saved: \(newValue)", category: .background)
        }
    }
    
    init(
        pokemonRepository: PokemonRepositoryProtocol,
        localRepository: LocalStorageRepositoryProtocol
    ) {
        self.pokemonRepository = pokemonRepository
        self.localRepository = localRepository
        
        // Initialize offset if first time
        if currentOffset == 0 {
            currentOffset = 5 // Start after initial 5
        }
    }
    
    /// Executes background fetch, fetching the next batch of Pokemon
    func execute() async throws -> [Pokemon] {
        AppLogger.info("Background fetch starting at offset: \(currentOffset)", category: .background)
        
        // Fetch next batch
        let newPokemon = try await pokemonRepository.fetchPokemonList(
            offset: currentOffset,
            limit: batchSize
        )
        
        AppLogger.info("Fetched \(newPokemon.count) basic Pokemon", category: .background)
        
        // Fetch details
        let detailedPokemon = try await pokemonRepository.fetchPokemonDetails(for: newPokemon)
        
        AppLogger.success("Got details for \(detailedPokemon.count) Pokemon", category: .background)
        
        // Load existing Pokemon
        let existingPokemon = try await localRepository.fetchAllPokemon()
        
        AppLogger.debug("Existing Pokemon count: \(existingPokemon.count)", category: .storage)
        
        // Combine and save (avoid duplicates by ID)
        var allPokemonDict = Dictionary(uniqueKeysWithValues: existingPokemon.map { ($0.id, $0) })
        detailedPokemon.forEach { allPokemonDict[$0.id] = $0 }
        let allPokemon = Array(allPokemonDict.values).sorted { $0.id < $1.id }
        
        try await localRepository.savePokemon(allPokemon)
        
        AppLogger.success("Saved total \(allPokemon.count) Pokemon", category: .storage)
        
        // Update offset for next fetch
        currentOffset += batchSize
        
        AppLogger.info("Next offset will be: \(currentOffset)", category: .background)
        
        return detailedPokemon
    }
    
    /// Resets the offset to start from the beginning
    func reset() {
        currentOffset = 5
        AppLogger.info("Offset reset to 5", category: .background)
    }
    
    /// Gets the current offset value
    func getCurrentOffset() -> Int {
        return currentOffset
    }
}
