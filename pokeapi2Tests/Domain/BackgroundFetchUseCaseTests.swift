//
//  BackgroundFetchUseCaseTests.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/29/25.
//



import XCTest
@testable import pokeapi2

/// Tests for BackgroundFetchUseCase offset tracking and batch fetching
final class BackgroundFetchUseCaseTests: XCTestCase {
    
    var sut: BackgroundFetchUseCase!
    var mockPokemonRepository: MockPokemonRepository!
    var mockLocalRepository: MockLocalStorageRepository!
    
    override func setUp() {
        super.setUp()
        
        // Reset UserDefaults offset
        UserDefaults.standard.removeObject(forKey: "BackgroundFetch.currentOffset")
        
        mockPokemonRepository = MockPokemonRepository()
        mockLocalRepository = MockLocalStorageRepository()
        
        sut = BackgroundFetchUseCase(
            pokemonRepository: mockPokemonRepository,
            localRepository: mockLocalRepository
        )
    }
    
    override func tearDown() {
        sut = nil
        mockPokemonRepository = nil
        mockLocalRepository = nil
        UserDefaults.standard.removeObject(forKey: "BackgroundFetch.currentOffset")
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testExecute_FirstTime_StartsAtOffset5() async throws {
        // Given
        mockPokemonRepository.mockPokemonList = TestData.makePokemonList(count: 5, startingId: 6)
        mockLocalRepository.storedPokemon = TestData.firstFivePokemon
        
        // When
        _ = try await sut.execute()
        
        // Then
        let newOffset = sut.getCurrentOffset()
        XCTAssertEqual(newOffset, 10, "Offset should be 10 after first fetch")
    }
    
    func testExecute_FetchesBatchOf5Pokemon() async throws {
        // Given
        let newBatch = TestData.makePokemonList(count: 5, startingId: 6)
        mockPokemonRepository.mockPokemonList = newBatch
        mockLocalRepository.storedPokemon = TestData.firstFivePokemon
        
        // When
        let result = try await sut.execute()
        
        // Then
        XCTAssertEqual(result.count, 5, "Should return 5 new pokemon")
        XCTAssertEqual(mockPokemonRepository.lastFetchedLimit, 5, "Should fetch limit of 5")
    }
    
    func testExecute_IncrementsOffsetAfterFetch() async throws {
        // Given
        mockPokemonRepository.mockPokemonList = TestData.makePokemonList(count: 5, startingId: 6)
        mockLocalRepository.storedPokemon = TestData.firstFivePokemon
        
        // When
        _ = try await sut.execute()
        
        // Then
        let newOffset = sut.getCurrentOffset()
        XCTAssertEqual(newOffset, 10, "Should increment offset to 10 after first fetch")
    }
    
    func testExecute_MultipleCalls_IncrementsOffsetCorrectly() async throws {
        // Given
        mockPokemonRepository.mockPokemonList = TestData.makePokemonList(count: 5)
        mockLocalRepository.storedPokemon = []
        
        // When - First call
        _ = try await sut.execute()
        let offsetAfterFirst = sut.getCurrentOffset()
        
        // Then
        XCTAssertEqual(offsetAfterFirst, 10, "Offset should be 10 after first fetch")
        
        // When - Second call
        _ = try await sut.execute()
        let offsetAfterSecond = sut.getCurrentOffset()
        
        // Then
        XCTAssertEqual(offsetAfterSecond, 15, "Offset should be 15 after second fetch")
    }
    
    func testExecute_CombinesNewPokemonWithExisting() async throws {
        // Given
        let existingPokemon = TestData.firstFivePokemon // IDs 1-5
        let newPokemon = TestData.makePokemonList(count: 5, startingId: 6) // IDs 6-10
        
        mockLocalRepository.storedPokemon = existingPokemon
        mockPokemonRepository.mockPokemonList = newPokemon
        
        // When
        _ = try await sut.execute()
        
        // Then
        XCTAssertEqual(mockLocalRepository.storedPokemon.count, 10, "Should have 10 total pokemon")
        let ids = mockLocalRepository.storedPokemon.map { $0.id }.sorted()
        XCTAssertEqual(ids, Array(1...10), "Should have pokemon with IDs 1-10")
    }
    
    func testExecute_AvoidsDuplicates() async throws {
        // Given - Existing pokemon with ID 1
        let existingPokemon = [TestData.bulbasaur]
        mockLocalRepository.storedPokemon = existingPokemon
        
        // New fetch also returns pokemon with ID 1 (duplicate)
        let newPokemon = [TestData.bulbasaur, TestData.ivysaur]
        mockPokemonRepository.mockPokemonList = newPokemon
        
        // When
        _ = try await sut.execute()
        
        // Then
        let stored = mockLocalRepository.storedPokemon
        let bulbasaurCount = stored.filter { $0.id == 1 }.count
        XCTAssertEqual(bulbasaurCount, 1, "Should not have duplicate Bulbasaur")
    }
    
    func testReset_ResetsOffsetTo5() {
        // Given
        UserDefaults.standard.set(25, forKey: "BackgroundFetch.currentOffset")
        
        // When
        sut.reset()
        
        // Then
        let offset = sut.getCurrentOffset()
        XCTAssertEqual(offset, 5, "Reset should set offset back to 5")
    }
    
    func testExecute_SavesCombinedPokemonList() async throws {
        // Given
        mockPokemonRepository.mockPokemonList = TestData.makePokemonList(count: 5, startingId: 6)
        mockLocalRepository.storedPokemon = TestData.firstFivePokemon
        
        // When
        _ = try await sut.execute()
        
        // Then
        XCTAssertEqual(mockLocalRepository.saveCallCount, 1, "Should save once")
    }
    
    func testExecute_NetworkError_ThrowsError() async {
        // Given
        mockPokemonRepository.shouldThrowError = true
        mockPokemonRepository.errorToThrow = NetworkError.noInternetConnection
        
        // When/Then
        do {
            _ = try await sut.execute()
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is NetworkError, "Should throw NetworkError")
        }
    }
}
