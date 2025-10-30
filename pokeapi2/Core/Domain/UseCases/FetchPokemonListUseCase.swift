//
//  FetchPokemonListUseCase.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//
import Foundation

/// Use case for fetching Pokemon list with caching strategy
/// Implements the business logic for loading Pokemon data
final class FetchPokemonListUseCase {
    private let pokemonRepository: PokemonRepositoryProtocol
    private let localRepository: LocalStorageRepositoryProtocol
    private let backgroundFetchUseCase: BackgroundFetchUseCase
    
    init(
        pokemonRepository: PokemonRepositoryProtocol,
        localRepository: LocalStorageRepositoryProtocol,
        backgroundFetchUseCase: BackgroundFetchUseCase
    ) {
        self.pokemonRepository = pokemonRepository
        self.localRepository = localRepository
        self.backgroundFetchUseCase = backgroundFetchUseCase
    }
    
    /// Executes the use case with cache-first strategy
    /// - Parameters:
    ///   - offset: Starting position for pagination
    ///   - limit: Number of Pokemon to fetch
    ///   - forceRefresh: If true, bypasses cache and fetches from API
    /// - Returns: Array of Pokemon
    func execute(offset: Int, limit: Int, forceRefresh: Bool = false) async throws -> [Pokemon] {
        // If not forcing refresh and we have cached data, return it
        let hasCachedData = await localRepository.hasStoredData()
        if !forceRefresh && hasCachedData {
            return try await localRepository.fetchAllPokemon()
        }
        
        if forceRefresh {
            backgroundFetchUseCase.reset()
        }
        
        // Fetch from API
        let pokemon = try await pokemonRepository.fetchPokemonList(offset: offset, limit: limit)
        
        // Fetch details for richer data
        let detailedPokemon = try await pokemonRepository.fetchPokemonDetails(for: pokemon)
        
        // Cache the results
        try await localRepository.savePokemon(detailedPokemon)
        
        return detailedPokemon
    }
}
