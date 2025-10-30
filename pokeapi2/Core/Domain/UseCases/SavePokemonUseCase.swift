//
//  SavePokemonUseCase.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//


/// Use case for saving Pokemon to local storage
final class SavePokemonUseCase {
    private let localRepository: LocalStorageRepositoryProtocol
    
    init(localRepository: LocalStorageRepositoryProtocol) {
        self.localRepository = localRepository
    }
    
    func execute(pokemon: [Pokemon]) async throws {
        try await localRepository.savePokemon(pokemon)
    }
}
