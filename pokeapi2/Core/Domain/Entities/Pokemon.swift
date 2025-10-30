//
//  Pokemon.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//

import Foundation

/// Domain entity representing a Pokemon
/// This is the core business model, independent of any framework or data source
struct Pokemon: Identifiable, Equatable {
    let id: Int
    let name: String
    let url: String
    var imageURL: String {
        Constants.baseSpriteURLString + "\(id).png"
    }
    
    // Additional properties for richer data
    var types: [PokemonType]?
    var height: Int?
    var weight: Int?
    var abilities: [String]?
    var stats: [PokemonStat]?
    var cryURL: String?
    
    init(
        id: Int,
        name: String,
        url: String,
        types: [PokemonType]? = nil,
        height: Int? = nil,
        weight: Int? = nil,
        abilities: [String]? = nil,
        stats: [PokemonStat]? = nil,
        cryURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.types = types
        self.height = height
        self.weight = weight
        self.abilities = abilities
        self.stats = stats
        self.cryURL = cryURL
    }
}

// MARK: - Pokemon Stats

struct PokemonStat: Equatable, Codable {
    let name: String
    let baseStat: Int
    let effort: Int
    
    var displayName: String {
        switch name {
        case "hp": return "HP"
        case "attack": return "Attack"
        case "defense": return "Defense"
        case "special-attack": return "Sp. Atk"
        case "special-defense": return "Sp. Def"
        case "speed": return "Speed"
        default: return name.capitalized
        }
    }
    
    var maxStat: Int {
        // Most Pokemon stats max around 255
        return 255
    }
    
    var percentage: Double {
        return Double(baseStat) / Double(maxStat)
    }
}


// MARK: - Supporting Types

enum PokemonType: String, Codable, CaseIterable {
    case normal, fire, water, electric, grass, ice
    case fighting, poison, ground, flying, psychic
    case bug, rock, ghost, dragon, dark, steel, fairy
    
    var color: String {
        switch self {
        case .fire: return "#F08030"
        case .water: return "#6890F0"
        case .grass: return "#78C850"
        case .electric: return "#F8D030"
        case .normal: return "#A8A878"
        case .ice: return "#98D8D8"
        case .fighting: return "#C03028"
        case .poison: return "#A040A0"
        case .ground: return "#E0C068"
        case .flying: return "#A890F0"
        case .psychic: return "#F85888"
        case .bug: return "#A8B820"
        case .rock: return "#B8A038"
        case .ghost: return "#705898"
        case .dragon: return "#7038F8"
        case .dark: return "#705848"
        case .steel: return "#B8B8D0"
        case .fairy: return "#EE99AC"
        }
    }
    
    var iconName: String {
        "type_\(rawValue)"
    }
}

// MARK: - Convenience Extensions

extension Pokemon {
    /// Returns a capitalized version of the Pokemon name
    var displayName: String {
        name.capitalized
    }
    
    /// Checks if the Pokemon matches a search query
    func matches(searchQuery: String) -> Bool {
        guard !searchQuery.isEmpty else { return true }
        return name.localizedCaseInsensitiveContains(searchQuery) ||
               "\(id)".contains(searchQuery)
    }
    
    /// Returns total base stats
    var totalStats: Int {
        stats?.reduce(0) { $0 + $1.baseStat } ?? 0
    }
}


