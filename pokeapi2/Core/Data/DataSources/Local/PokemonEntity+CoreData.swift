//
//  PokemonEntity+CoreData.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//

import CoreData

/// Core Data entity for storing Pokemon
/// This maps our domain model to the database
@objc(PokemonEntity)
public class PokemonEntityModel: NSManagedObject {
    @NSManaged public var id: Int32
    @NSManaged public var name: String
    @NSManaged public var url: String
    @NSManaged public var types: String? // Stored as comma-separated string
    @NSManaged public var height: Int32
    @NSManaged public var weight: Int32
    @NSManaged public var abilities: String? // Stored as comma-separated string
    @NSManaged public var stats: String? // Stored as JSON string
    @NSManaged public var cryURL: String? // Audio URL
}

// MARK: - Fetch Request

extension PokemonEntityModel {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PokemonEntityModel> {
        return NSFetchRequest<PokemonEntityModel>(entityName: "PokemonEntity")
    }
}

// MARK: - Domain Model Conversion

extension PokemonEntityModel {
    /// Converts Core Data entity to domain model
    func toDomain() -> Pokemon {
        let pokemonTypes = types?
            .split(separator: ",")
            .compactMap { PokemonType(rawValue: String($0)) } ?? []
        
        let pokemonAbilities = abilities?
            .split(separator: ",")
            .map { String($0) } ?? []
        
        // Decode stats from JSON
        var pokemonStats: [PokemonStat]? = nil
        if let statsJSON = stats, let data = statsJSON.data(using: .utf8) {
            pokemonStats = try? JSONDecoder().decode([PokemonStat].self, from: data)
        }
        
        return Pokemon(
            id: Int(id),
            name: name,
            url: url,
            types: pokemonTypes.isEmpty ? nil : pokemonTypes,
            height: height > 0 ? Int(height) : nil,
            weight: weight > 0 ? Int(weight) : nil,
            abilities: pokemonAbilities.isEmpty ? nil : pokemonAbilities,
            stats: pokemonStats,
            cryURL: cryURL
        )
    }
    
    /// Updates Core Data entity from domain model
    func update(from pokemon: Pokemon) {
        self.id = Int32(pokemon.id)
        self.name = pokemon.name
        self.url = pokemon.url
        self.types = pokemon.types?.map { $0.rawValue }.joined(separator: ",")
        self.height = Int32(pokemon.height ?? 0)
        self.weight = Int32(pokemon.weight ?? 0)
        self.abilities = pokemon.abilities?.joined(separator: ",")
        self.cryURL = pokemon.cryURL
        
        // Encode stats to JSON
        if let stats = pokemon.stats,
           let data = try? JSONEncoder().encode(stats),
           let jsonString = String(data: data, encoding: .utf8) {
            self.stats = jsonString
        } else {
            self.stats = nil
        }
    }
    
    /// Creates a new Core Data entity from domain model
    static func create(from pokemon: Pokemon, context: NSManagedObjectContext) -> PokemonEntityModel {
        let entity = PokemonEntityModel(context: context)
        entity.update(from: pokemon)
        return entity
    }
}

// MARK: - Identifiable Conformance

extension PokemonEntityModel: Identifiable {}
