//
//  TestData.swift
//  pokeapi2Tests
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/29/25.
//
import Foundation
@testable import pokeapi2

/// Helper struct containing test data for unit tests
struct TestData {
    
    // MARK: - Sample Pokemon
    
    static let bulbasaur = Pokemon(
        id: 1,
        name: "bulbasaur",
        url: Constants.baseURLString + "pokemon/1/",
        types: [.grass, .poison],
        height: 7,
        weight: 69,
        abilities: ["overgrow", "chlorophyll"]
    )
    
    static let ivysaur = Pokemon(
        id: 2,
        name: "ivysaur",
        url: Constants.baseURLString + "pokemon/2/",
        types: [.grass, .poison],
        height: 10,
        weight: 130,
        abilities: ["overgrow", "chlorophyll"]
    )
    
    static let venusaur = Pokemon(
        id: 3,
        name: "venusaur",
        url: Constants.baseURLString + "pokemon/2/",
        types: [.grass, .poison],
        height: 20,
        weight: 1000,
        abilities: ["overgrow", "chlorophyll"]
    )

    static let charmander = Pokemon(
        id: 4,
        name: "charmander",
        url: Constants.baseURLString + "pokemon/4/",
        types: [.fire],
        height: 6,
        weight: 85,
        abilities: ["blaze", "solar-power"]
    )

    static let charmeleon = Pokemon(
        id: 5,
        name: "charmeleon",
        url: Constants.baseURLString + "pokemon/5/",
        types: [.fire],
        height: 11,
        weight: 190,
        abilities: ["blaze", "solar-power"]
    )
    
    static let squirtle = Pokemon(
        id: 7,
        name: "squirtle",
        url: Constants.baseURLString + "pokemon/7/",
        types: [.water],
        height: 5,
        weight: 90,
        abilities: ["torrent", "rain-dish"]
    )
    
    static let pikachu = Pokemon(
        id: 25,
        name: "pikachu",
        url: Constants.baseURLString + "pokemon/25/",
        types: [.electric],
        height: 4,
        weight: 60,
        abilities: ["static", "lightning-rod"]
    )
    
    // MARK: - Sample Lists
    
    static var starterPokemon: [Pokemon] {
        [bulbasaur, charmander, squirtle]
    }
    
    static var firstFivePokemon: [Pokemon] {
        [bulbasaur, ivysaur, venusaur, charmander, charmeleon]
    }
    
    // MARK: - Factory Methods
    
    static func makePokemon(id: Int, name: String) -> Pokemon {
        Pokemon(
            id: id,
            name: name,
            url: Constants.baseURLString + "pokemon/\(id)/",
            types: [.normal],
            height: 10,
            weight: 100,
            abilities: ["test-ability"]
        )
    }
    
    static func makePokemonList(count: Int, startingId: Int = 1) -> [Pokemon] {
        (startingId..<(startingId + count)).map { id in
            makePokemon(id: id, name: "pokemon\(id)")
        }
    }
}
