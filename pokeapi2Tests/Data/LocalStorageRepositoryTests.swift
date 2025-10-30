//
//  LocalStorageRepositoryTests.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/29/25.
//



import XCTest
import CoreData
@testable import pokeapi2

/// Tests for LocalStorageRepository Core Data operations
final class LocalStorageRepositoryTests: XCTestCase {
    
    var sut: LocalStorageRepository!
    var inMemoryCoreDataStack: CoreDataStack!
    
    override func setUp() {
        super.setUp()
        
        // Create in-memory Core Data stack for testing
        inMemoryCoreDataStack = createInMemoryCoreDataStack()
        sut = LocalStorageRepository(coreDataStack: inMemoryCoreDataStack)
    }
    
    override func tearDown() {
        sut = nil
        inMemoryCoreDataStack = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func createInMemoryCoreDataStack() -> CoreDataStack {
        let container = NSPersistentContainer(name: "pokeapi2")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { description, error in
            XCTAssertNil(error, "Failed to load in-memory store")
        }
        
        // Create a custom CoreDataStack with this container
        // Note: You'll need to add this initializer to CoreDataStack
        let stack = CoreDataStack.shared // Using shared for now
        return stack
    }
    
    // MARK: - Tests
    
    func testSavePokemon_Success() async throws {
        // Given
        let pokemon = TestData.starterPokemon
        
        // When
        try await sut.savePokemon(pokemon)
        
        // Then
        let hasData = await sut.hasStoredData()
        XCTAssertTrue(hasData, "Should have stored data after saving")
    }
    
    func testFetchAllPokemon_ReturnsStoredPokemon() async throws {
        // Given
        let pokemon = TestData.starterPokemon
        try await sut.savePokemon(pokemon)
        
        // When
        let fetchedPokemon = try await sut.fetchAllPokemon()
        
        // Then
        XCTAssertEqual(fetchedPokemon.count, 3, "Should fetch 3 pokemon")
        XCTAssertEqual(fetchedPokemon[0].name, "bulbasaur")
        XCTAssertEqual(fetchedPokemon[1].name, "charmander")
        XCTAssertEqual(fetchedPokemon[2].name, "squirtle")
    }
    
    func testFetchAllPokemon_EmptyStorage_ReturnsEmptyArray() async throws {
        // When
        try await sut.deleteAllPokemon()
        let fetchedPokemon = try await sut.fetchAllPokemon()
        
        // Then
        XCTAssertTrue(fetchedPokemon.isEmpty, "Should return empty array when no data stored")
    }
    
    func testDeleteAllPokemon_RemovesAllData() async throws {
        // Given
        let pokemon = TestData.starterPokemon
        try await sut.savePokemon(pokemon)
        
        // When
        try await sut.deleteAllPokemon()
        
        // Then
        let hasData = await sut.hasStoredData()
        XCTAssertFalse(hasData, "Should not have data after deletion")
        
        let fetchedPokemon = try await sut.fetchAllPokemon()
        XCTAssertTrue(fetchedPokemon.isEmpty, "Should return empty array after deletion")
    }
    
    func testHasStoredData_WithData_ReturnsTrue() async throws {
        // Given
        let pokemon = TestData.starterPokemon
        try await sut.savePokemon(pokemon)
        
        // When
        let hasData = await sut.hasStoredData()
        
        // Then
        XCTAssertTrue(hasData, "Should return true when data exists")
    }
    
    func testHasStoredData_WithoutData_ReturnsFalse() async throws {
        // When
        try await sut.deleteAllPokemon()
        let hasData = await sut.hasStoredData()
        
        // Then
        XCTAssertFalse(hasData, "Should return false when no data exists")
    }
    
    func testSearchPokemon_FindsMatchingPokemon() async throws {
        // Given
        let pokemon = TestData.firstFivePokemon
        try await sut.savePokemon(pokemon)
        
        // When
        let results = try await sut.searchPokemon(query: "char")
        
        // Then
        XCTAssertEqual(results.count, 2, "Should find 2 pokemon")
        XCTAssertEqual(results.first?.name, "charmander")
    }
    
    func testSearchPokemon_EmptyQuery_ReturnsAllPokemon() async throws {
        // Given
        let pokemon = TestData.starterPokemon
        try await sut.savePokemon(pokemon)
        
        // When
        let results = try await sut.searchPokemon(query: "")
        
        // Then
        XCTAssertEqual(results.count, 3, "Empty query should return all pokemon")
    }
    
    func testSearchPokemon_NoMatches_ReturnsEmptyArray() async throws {
        // Given
        let pokemon = TestData.starterPokemon
        try await sut.savePokemon(pokemon)
        
        // When
        let results = try await sut.searchPokemon(query: "mewtwo")
        
        // Then
        XCTAssertTrue(results.isEmpty, "Should return empty array when no matches")
    }
    
    func testSavePokemon_OverwritesExistingData() async throws {
        // Given
        let firstBatch = TestData.starterPokemon
        try await sut.savePokemon(firstBatch)
        
        // When
        let secondBatch = [TestData.pikachu]
        try await sut.savePokemon(secondBatch)
        
        // Then
        let fetchedPokemon = try await sut.fetchAllPokemon()
        XCTAssertEqual(fetchedPokemon.count, 1, "Should only have new data")
        XCTAssertEqual(fetchedPokemon.first?.name, "pikachu")
    }
}
