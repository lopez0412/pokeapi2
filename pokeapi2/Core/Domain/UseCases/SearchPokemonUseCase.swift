//
//  SearchPokemonUseCase.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//


/// Use case for searching Pokemon by name or ID
final class SearchPokemonUseCase {
    private let localRepository: LocalStorageRepositoryProtocol
    
    init(localRepository: LocalStorageRepositoryProtocol) {
        self.localRepository = localRepository
    }
    
    func execute(query: String) async throws -> [Pokemon] {
        return try await localRepository.searchPokemon(query: query)
    }
}