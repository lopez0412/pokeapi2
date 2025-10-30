//
//  PomonListDTO.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//

import Foundation

/// Data Transfer Object for Pokemon list response from PokeAPI
/// Separates API structure from domain model (Clean Architecture)
struct PokemonListDTO: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonBasicDTO]
}

struct PokemonBasicDTO: Decodable {
    let name: String
    let url: String
    
    var id: Int {
        // Remove trailing slash if present
        let cleanURL = url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        // Split and get last component
        let components = cleanURL.split(separator: "/")
        
        guard let lastComponent = components.last,
              let id = Int(lastComponent) else {
            return 0
        }
        
        return id
    }
}

// MARK: - DTO to Domain Mapping

extension PokemonBasicDTO {
    /// Converts DTO to domain entity
    func toDomain() -> Pokemon {
        Pokemon(
            id: self.id,
            name: self.name,
            url: self.url
        )
    }
}

extension PokemonListDTO {
    /// Converts list of DTOs to domain entities
    func toDomain() -> [Pokemon] {
        results.map { $0.toDomain() }
    }
}
