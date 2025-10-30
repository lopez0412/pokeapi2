//
//  MockPokemonRepository.swift
//  pokeapi2Tests
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/29/25.
//
import Foundation
@testable import pokeapi2

/// Mock implementation of PokemonRepositoryProtocol for testing
final class MockPokemonRepository: PokemonRepositoryProtocol {
    
    // Control what the mock returns
    var mockPokemonList: [Pokemon] = []
    var mockPokemonDetail: Pokemon?
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.noData
    
    // Track method calls
    var fetchListCallCount = 0
    var fetchDetailCallCount = 0
    var lastFetchedOffset: Int?
    var lastFetchedLimit: Int?
    var lastFetchedId: Int?
    
    func fetchPokemonList(offset: Int, limit: Int) async throws -> [Pokemon] {
        fetchListCallCount += 1
        lastFetchedOffset = offset
        lastFetchedLimit = limit
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockPokemonList
    }
    
    func fetchPokemonDetail(id: Int) async throws -> Pokemon {
        fetchDetailCallCount += 1
        lastFetchedId = id
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        guard let detail = mockPokemonDetail else {
            throw NetworkError.noData
        }
        
        return detail
    }
    
    func fetchPokemonDetails(for basicPokemon: [Pokemon]) async throws -> [Pokemon] {
        if shouldThrowError {
            throw errorToThrow
        }
        
        // Return the same pokemon with mock details
        return basicPokemon
    }
    
    // Helper to reset mock state
    func reset() {
        mockPokemonList = []
        mockPokemonDetail = nil
        shouldThrowError = false
        fetchListCallCount = 0
        fetchDetailCallCount = 0
        lastFetchedOffset = nil
        lastFetchedLimit = nil
        lastFetchedId = nil
    }
}

// pokeapi2Tests/Mocks/MockLocalStorageRepository.swift

/// Mock implementation of LocalStorageRepositoryProtocol for testing
final class MockLocalStorageRepository: LocalStorageRepositoryProtocol {
    
    // In-memory storage for testing - PUBLIC so tests can access it
    var storedPokemon: [Pokemon] = []
    
    // Control mock behavior
    var shouldThrowError = false
    var errorToThrow: Error = StorageError.saveFailed(NSError(domain: "Test", code: -1))
    
    // Track method calls
    var saveCallCount = 0
    var fetchAllCallCount = 0
    var deleteAllCallCount = 0
    var searchCallCount = 0
    var hasStoredDataCallCount = 0
    
    func savePokemon(_ pokemon: [Pokemon]) async throws {
        saveCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        storedPokemon = pokemon
        print("Mock saved \(pokemon.count) pokemon")
    }
    
    func fetchAllPokemon() async throws -> [Pokemon] {
        fetchAllCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        print("Mock returning \(storedPokemon.count) pokemon")
        return storedPokemon
    }
    
    func deleteAllPokemon() async throws {
        deleteAllCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        storedPokemon = []
    }
    
    func hasStoredData() async -> Bool {
        hasStoredDataCallCount += 1
        return !storedPokemon.isEmpty
    }
    
    func searchPokemon(query: String) async throws -> [Pokemon] {
        searchCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return storedPokemon.filter { $0.matches(searchQuery: query) }
    }
    
    // Helper to reset mock state
    func reset() {
        storedPokemon = []
        shouldThrowError = false
        saveCallCount = 0
        fetchAllCallCount = 0
        deleteAllCallCount = 0
        searchCallCount = 0
        hasStoredDataCallCount = 0
    }
}
