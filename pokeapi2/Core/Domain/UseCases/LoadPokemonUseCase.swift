//
//  LoadPokemonUseCase.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//


/// Use case for loading Pokemon from local storage
final class LoadPokemonUseCase {
    private let localRepository: LocalStorageRepositoryProtocol
    
    init(localRepository: LocalStorageRepositoryProtocol) {
        self.localRepository = localRepository
    }
    
    func execute() async throws -> [Pokemon] {
        return try await localRepository.fetchAllPokemon()
    }
}