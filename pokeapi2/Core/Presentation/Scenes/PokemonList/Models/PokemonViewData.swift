//
//  PokemonViewData.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//
import Foundation

/// Presentation model for Pokemon display
/// Separates domain model from view concerns (Clean Architecture)
struct PokemonViewData: Identifiable, Hashable {
    let id: Int
    let name: String
    let imageURL: String
    let types: [PokemonType]
    
    var typesText: String {
        types.map { $0.rawValue.capitalized }.joined(separator: ", ")
    }
    
    var primaryType: PokemonType? {
        types.first
    }
}
