//
//  FetchPokemonListUseCaseTests.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/29/25.
//



import XCTest
@testable import pokeapi2

/// Tests for FetchPokemonListUseCase business logic
final class FetchPokemonListUseCaseTests: XCTestCase {
    
    var sut: FetchPokemonListUseCase!
    var mockPokemonRepository: MockPokemonRepository!
    var mockLocalRepository: MockLocalStorageRepository!
    var mockBackgroundFetchUseCase: BackgroundFetchUseCase!
    
    override func setUp() {
        super.setUp()
        
        mockPokemonRepository = MockPokemonRepository()
        mockLocalRepository = MockLocalStorageRepository()
        
        // Create real BackgroundFetchUseCase for testing
        mockBackgroundFetchUseCase = BackgroundFetchUseCase(
            pokemonRepository: mockPokemonRepository,
            localRepository: mockLocalRepository
        )
        
        sut = FetchPokemonListUseCase(
            pokemonRepository: mockPokemonRepository,
            localRepository: mockLocalRepository,
            backgroundFetchUseCase: mockBackgroundFetchUseCase
        )
    }
    
    override func tearDown() {
        sut = nil
        mockPokemonRepository = nil
        mockLocalRepository = nil
        mockBackgroundFetchUseCase = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testExecute_WithCachedData_ReturnsCachedPokemon() async throws {
        // Given
        let cachedPokemon = TestData.starterPokemon
        mockLocalRepository.storedPokemon = cachedPokemon
        
        // When
        let result = try await sut.execute(offset: 0, limit: 5, forceRefresh: false)
        
        // Then
        XCTAssertEqual(result.count, 3, "Should return cached pokemon")
        XCTAssertEqual(mockLocalRepository.fetchAllCallCount, 1, "Should call fetchAll once")
        XCTAssertEqual(mockPokemonRepository.fetchListCallCount, 0, "Should not call API")
    }
    
    func testExecute_WithoutCachedData_FetchesFromAPI() async throws {
        // Given
        mockLocalRepository.storedPokemon = []
        mockPokemonRepository.mockPokemonList = TestData.firstFivePokemon
        
        // When
        let result = try await sut.execute(offset: 0, limit: 5, forceRefresh: false)
        
        // Then
        XCTAssertEqual(result.count, 5, "Should return fetched pokemon")
        XCTAssertEqual(mockPokemonRepository.fetchListCallCount, 1, "Should call API once")
        XCTAssertEqual(mockLocalRepository.saveCallCount, 1, "Should save to cache")
    }
    
    func testExecute_ForceRefresh_IgnoresCacheAndFetchesFromAPI() async throws {
        // Given
        mockLocalRepository.storedPokemon = TestData.starterPokemon
        mockPokemonRepository.mockPokemonList = TestData.firstFivePokemon
        
        // When
        let result = try await sut.execute(offset: 0, limit: 5, forceRefresh: true)
        
        // Then
        XCTAssertEqual(result.count, 5, "Should return fresh data from API")
        XCTAssertEqual(mockPokemonRepository.fetchListCallCount, 1, "Should call API")
        XCTAssertEqual(mockLocalRepository.fetchAllCallCount, 0, "Should not use cache")
    }
    
    func testExecute_ForceRefresh_ResetsBackgroundFetchOffset() async throws {
        // Given
        mockPokemonRepository.mockPokemonList = TestData.firstFivePokemon
        
        // Set background fetch offset to 10
        UserDefaults.standard.set(10, forKey: "BackgroundFetch.currentOffset")
        
        // When
        _ = try await sut.execute(offset: 0, limit: 5, forceRefresh: true)
        
        // Then
        let offset = mockBackgroundFetchUseCase.getCurrentOffset()
        XCTAssertEqual(offset, 5, "Should reset background fetch offset to 5")
    }
    
    func testExecute_SavesPokemonToLocalStorage() async throws {
        // Given
        mockLocalRepository.storedPokemon = []
        mockPokemonRepository.mockPokemonList = TestData.firstFivePokemon
        
        // When
        _ = try await sut.execute(offset: 0, limit: 5, forceRefresh: false)
        
        // Then
        XCTAssertEqual(mockLocalRepository.saveCallCount, 1, "Should save once")
        XCTAssertEqual(mockLocalRepository.storedPokemon.count, 5, "Should save 5 pokemon")
    }
    
    func testExecute_NetworkError_ThrowsError() async {
        // Given
        mockLocalRepository.storedPokemon = []
        mockPokemonRepository.shouldThrowError = true
        mockPokemonRepository.errorToThrow = NetworkError.noInternetConnection
        
        // When/Then
        do {
            _ = try await sut.execute(offset: 0, limit: 5, forceRefresh: false)
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is NetworkError, "Should throw NetworkError")
        }
    }
    
    func testExecute_UsesCorrectOffsetAndLimit() async throws {
        // Given
        mockLocalRepository.storedPokemon = []
        mockPokemonRepository.mockPokemonList = TestData.makePokemonList(count: 10)
        
        // When
        _ = try await sut.execute(offset: 5, limit: 10, forceRefresh: false)
        
        // Then
        XCTAssertEqual(mockPokemonRepository.lastFetchedOffset, 5, "Should use correct offset")
        XCTAssertEqual(mockPokemonRepository.lastFetchedLimit, 10, "Should use correct limit")
    }
}