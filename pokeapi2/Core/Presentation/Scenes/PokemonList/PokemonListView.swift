//
//  ContentView.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//
import SwiftUI

/// Main Pokemon list view
/// Displays a scrollable list of Pokemon with search functionality
struct PokemonListView: View {
    @StateObject var viewModel: PokemonListViewModel
    let coordinator: PokemonListCoordinator
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.appBackground
                    .ignoresSafeArea()
                
                // Main content
                contentView
                
                // Loading overlay
                if viewModel.isLoading && viewModel.pokemon.isEmpty {
                    LoadingView()
                }
                
                if !viewModel.networkMonitor.isConnected {
                    Text("No internet connection")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                }
            }
            .navigationTitle("Pokédex")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        BackgroundTaskManager.shared.triggerBackgroundFetchManually()
                    } label: {
                        Image(systemName: "arrow.clockwise.circle.fill")
                    }
                }
            }
            .searchable(text: $viewModel.searchQuery, prompt: "Search Pokemon")
            .refreshable {
                viewModel.refreshPokemon()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .onAppear {
                if viewModel.pokemon.isEmpty {
                    viewModel.loadPokemon()
                }
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.filteredPokemon.isEmpty && !viewModel.isLoading {
            EmptyStateView(
                message: viewModel.searchQuery.isEmpty
                ? "No Pokemon found. Pull to refresh."
                : "No Pokemon match your search."
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredPokemon) { pokemon in
                        NavigationLink {
                            coordinator.showPokemonDetail(pokemon: pokemon)
                        } label: {
                            PokemonCell(viewData: viewModel.viewData(for: pokemon))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    PokemonListCoordinator().start()
}
