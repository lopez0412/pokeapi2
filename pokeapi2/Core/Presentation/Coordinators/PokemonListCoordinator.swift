//
//  PokemonListCoordinator.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//

import Foundation
import SwiftUI
/// Coordinator for Pokemon List flow
final class PokemonListCoordinator: Coordinator {
    @ViewBuilder
    func start() -> some View {
        let localRepository = LocalStorageRepository()
        let backgroundFetchUseCase = makeBackgroundFetchUseCase()
        
        let viewModel = PokemonListViewModel(
            fetchPokemonUseCase: makeFetchPokemonUseCase(backgroundFetchUseCase: backgroundFetchUseCase),
            searchPokemonUseCase: makeSearchPokemonUseCase(),
            localRepository: localRepository
        )
        
        PokemonListView(viewModel: viewModel, coordinator: self)
    }
    
    // MARK: - Navigation
    
    func showPokemonDetail(pokemon: Pokemon) -> some View {
        PokemonDetailView(pokemon: pokemon)
    }
    
    // MARK: - Dependency Factory
    
    private func makeFetchPokemonUseCase(backgroundFetchUseCase: BackgroundFetchUseCase) -> FetchPokemonListUseCase {
        let networkClient = NetworkClient()
        let pokemonRepository = PokemonRepository(networkClient: networkClient)
        let localRepository = LocalStorageRepository()
        
        return FetchPokemonListUseCase(
            pokemonRepository: pokemonRepository,
            localRepository: localRepository,
            backgroundFetchUseCase: backgroundFetchUseCase
        )
    }
    
    private func makeSearchPokemonUseCase() -> SearchPokemonUseCase {
        let localRepository = LocalStorageRepository()
        return SearchPokemonUseCase(localRepository: localRepository)
    }
    
    private func makeBackgroundFetchUseCase() -> BackgroundFetchUseCase {
        let networkClient = NetworkClient()
        let pokemonRepository = PokemonRepository(networkClient: networkClient)
        let localRepository = LocalStorageRepository()
        
        return BackgroundFetchUseCase(
            pokemonRepository: pokemonRepository,
            localRepository: localRepository
        )
    }
}
