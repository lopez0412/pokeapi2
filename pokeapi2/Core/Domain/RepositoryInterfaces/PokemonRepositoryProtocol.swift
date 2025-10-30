//
//  PokemonRepositoryProtocol.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//

import Foundation

protocol PokemonRepositoryProtocol {
    func fetchPokemonList(offset: Int, limit: Int) async throws -> [Pokemon]
    func fetchPokemonDetail(id: Int) async throws -> Pokemon
    func fetchPokemonDetails(for basicPokemon: [Pokemon]) async throws -> [Pokemon]
}
