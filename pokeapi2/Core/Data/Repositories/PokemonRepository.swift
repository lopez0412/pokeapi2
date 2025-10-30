//
//  PokemonRepository.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//

import Foundation

/// Concrete implementation of PokemonRepositoryProtocol
/// Handles fetching Pokemon data from the remote API
/// Uses Dependency Injection for NetworkClient (testability)
final class PokemonRepository: PokemonRepositoryProtocol {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    /// Fetches a paginated list of Pokemon from PokeAPI
    func fetchPokemonList(offset: Int, limit: Int) async throws -> [Pokemon] {
        let endpoint = APIEndpoint.pokemonList(offset: offset, limit: limit)
        let response = try await networkClient.request(endpoint, responseType: PokemonListDTO.self)
        return response.toDomain()
    }
    
    /// Fetches detailed information for a specific Pokemon
    func fetchPokemonDetail(id: Int) async throws -> Pokemon {
        let endpoint = APIEndpoint.pokemonDetail(id: id)
        let response = try await networkClient.request(endpoint, responseType: PokemonDetailDTO.self)
        return response.toDomain()
    }
    
    /// Fetches details for multiple Pokemon concurrently
    /// Uses TaskGroup for efficient parallel fetching
    func fetchPokemonDetails(for basicPokemon: [Pokemon]) async throws -> [Pokemon] {
            return try await withThrowingTaskGroup(of: Pokemon.self) { group in
                for pokemon in basicPokemon {
                    group.addTask {
                        try await self.fetchPokemonDetail(id: pokemon.id)
                    }
                }
                
                var detailedPokemon: [Pokemon] = []
                for try await pokemon in group {
                    detailedPokemon.append(pokemon)
                }
                
                return detailedPokemon.sorted { $0.id < $1.id }
            }
        }
}
