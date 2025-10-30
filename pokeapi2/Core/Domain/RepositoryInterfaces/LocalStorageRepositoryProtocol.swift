//
//  LocalStorageRepositoryProtocol.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//

import Foundation

protocol LocalStorageRepositoryProtocol {
    func savePokemon(_ pokemon: [Pokemon]) async throws
    func fetchAllPokemon() async throws -> [Pokemon]
    func searchPokemon(query: String) async throws -> [Pokemon]
    func deleteAllPokemon() async throws
    func hasStoredData() async -> Bool
}
