//
//  PokemonListViewModel.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//
import Foundation
import Combine

/// ViewModel for Pokemon List screen
/// Follows MVVM pattern - handles presentation logic and state management
@MainActor
final class PokemonListViewModel: ObservableObject {
    // MARK: - Published Properties (State that the View observes)
    @Published var networkMonitor = NetworkMonitor.shared
    @Published var pokemon: [Pokemon] = []
    @Published var filteredPokemon: [Pokemon] = []
    @Published var searchQuery: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    // MARK: - Private Properties
    
    private let fetchPokemonUseCase: FetchPokemonListUseCase
    private let searchPokemonUseCase: SearchPokemonUseCase
    private let localRepository: LocalStorageRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private let initialOffset = 0
    private let initialLimit = 5
    
    // MARK: - Initialization
    
    init(
        fetchPokemonUseCase: FetchPokemonListUseCase,
        searchPokemonUseCase: SearchPokemonUseCase,
        localRepository: LocalStorageRepositoryProtocol
    ) {
        self.fetchPokemonUseCase = fetchPokemonUseCase
        self.searchPokemonUseCase = searchPokemonUseCase
        self.localRepository = localRepository
        
        setupSearchDebounce()
        observeBackgroundFetchCompletion()
    }
    
    // MARK: - Public Methods (Called by the View)
    
    /// Loads initial Pokemon list
    func loadPokemon() {
        Task {
            await fetchPokemon(forceRefresh: false)
        }
    }
    
    /// Refreshes Pokemon list from API
    func refreshPokemon() {
        Task {
            await fetchPokemon(forceRefresh: true)
        }
    }
    
    /// Clears the current error
    func clearError() {
        errorMessage = nil
        showError = false
    }
    
    // MARK: - Private Methods
    
    private func fetchPokemon(forceRefresh: Bool) async {
        isLoading = true
        clearError()
        
        do {
            let fetchedPokemon = try await fetchPokemonUseCase.execute(
                offset: initialOffset,
                limit: initialLimit,
                forceRefresh: forceRefresh
            )
            
            pokemon = fetchedPokemon
            filteredPokemon = fetchedPokemon
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    private func setupSearchDebounce() {
        // Debounce search to avoid excessive queries
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) {
        Task {
            do {
                if query.isEmpty {
                    filteredPokemon = pokemon
                } else {
                    let results = try await searchPokemonUseCase.execute(query: query)
                    filteredPokemon = results
                }
            } catch {
                handleError(error)
            }
        }
    }
    
    private func handleError(_ error: Error) {
        AppLogger.error("ViewModel error", error: error, category: .viewModel)
        if let networkError = error as? NetworkError {
            errorMessage = networkError.errorDescription
        } else if let storageError = error as? StorageError {
            errorMessage = storageError.errorDescription
        } else {
            errorMessage = "An unexpected error occurred. Please try again."
        }
        showError = true
    }
    
    // MARK: - Background Fetch Observer

    private func observeBackgroundFetchCompletion() {
        NotificationCenter.default.publisher(for: NSNotification.Name("BackgroundFetchCompleted"))
            .sink { [weak self] notification in
                
                // Reload from local storage
                Task { @MainActor in
                    guard let self = self else { return }
                    do {
                        let updatedPokemon = try await self.localRepository.fetchAllPokemon()
                        self.pokemon = updatedPokemon
                        self.filteredPokemon = self.searchQuery.isEmpty ? updatedPokemon : self.filteredPokemon
                        
                    } catch {
                        AppLogger.error("Failed to refresh after background fetch:", error: error, category: .viewModel)
                    }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - View Data Transformation

extension PokemonListViewModel {
    /// Returns display data for a Pokemon
    func viewData(for pokemon: Pokemon) -> PokemonViewData {
        PokemonViewData(
            id: pokemon.id,
            name: pokemon.displayName,
            imageURL: pokemon.imageURL,
            types: pokemon.types ?? []
        )
    }
}
