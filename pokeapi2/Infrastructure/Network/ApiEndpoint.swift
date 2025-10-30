//
//  ApiEndpoint.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//

import Foundation

/// Defines API endpoints for PokeAPI
/// Following the Open/Closed principle - easy to extend with new endpoints
enum APIEndpoint {
    case pokemonList(offset: Int, limit: Int)
    case pokemonDetail(id: Int)
    case pokemonDetailByName(name: String)
    
    private var baseURL: String {
        "https://pokeapi.co/api/v2"
    }
    
    var url: URL? {
        switch self {
        case .pokemonList(let offset, let limit):
            return URL(string: "\(baseURL)/pokemon?offset=\(offset)&limit=\(limit)")
            
        case .pokemonDetail(let id):
            return URL(string: "\(baseURL)/pokemon/\(id)")
            
        case .pokemonDetailByName(let name):
            return URL(string: "\(baseURL)/pokemon/\(name)")
        }
    }
    
    var httpMethod: String {
        return "GET"
    }
    
    var headers: [String: String] {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}

// MARK: - URL Request Builder

extension APIEndpoint {
    /// Creates a configured URLRequest for the endpoint
    func makeRequest() throws -> URLRequest {
        guard let url = url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.timeoutInterval = 30
        
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}
