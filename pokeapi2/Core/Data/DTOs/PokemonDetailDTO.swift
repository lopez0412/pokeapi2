//
//  PokemonDTO.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//

import Foundation

/// Data Transfer Object for detailed Pokemon response from PokeAPI
struct PokemonDetailDTO: Decodable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let types: [PokemonTypeSlot]
    let abilities: [PokemonAbilitySlot]
    let sprites: PokemonSprites
    let stats: [PokemonStatSlot]
    let cries: PokemonCries?
}

struct PokemonTypeSlot: Decodable {
    let slot: Int
    let type: PokemonTypeDTO
}

struct PokemonTypeDTO: Decodable {
    let name: String
    let url: String
}

struct PokemonAbilitySlot: Decodable {
    let ability: PokemonAbilityDTO
    let isHidden: Bool
    let slot: Int
}

struct PokemonAbilityDTO: Decodable {
    let name: String
    let url: String
}

struct PokemonSprites: Decodable {
    let frontDefault: String?
    let frontShiny: String?
    let backDefault: String?
    let backShiny: String?
    
    var primaryImage: String {
        frontDefault ?? frontShiny ?? ""
    }
}

struct PokemonStatSlot: Decodable {
    let baseStat: Int
    let effort: Int
    let stat: PokemonStatDTO
}

struct PokemonStatDTO: Decodable {
    let name: String
    let url: String
}

struct PokemonCries: Decodable {
    let latest: String?
    let legacy: String?
    
    var primaryCry: String? {
        latest ?? legacy
    }
}


// MARK: - Detailed DTO to Domain Mapping


extension PokemonDetailDTO {
    /// Converts detailed DTO to domain entity
    func toDomain() -> Pokemon {
        let pokemonTypes = types.compactMap { slot -> PokemonType? in
            PokemonType(rawValue: slot.type.name)
        }
        
        let abilityNames = abilities.map { $0.ability.name }
        
        let pokemonStats = stats.map { slot -> PokemonStat in
            PokemonStat(
                name: slot.stat.name,
                baseStat: slot.baseStat,
                effort: slot.effort
            )
        }
        
        return Pokemon(
            id: id,
            name: name,
            url: Constants.baseURLString + "pokemon/\(id)/",
            types: pokemonTypes,
            height: height,
            weight: weight,
            abilities: abilityNames,
            stats: pokemonStats,
            cryURL: cries?.primaryCry
        )
    }
}
