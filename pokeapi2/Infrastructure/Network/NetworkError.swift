//
//  NetworkError.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//
import Foundation

/// Custom error types for network operations
/// Provides user-friendly error messages and detailed debugging info
enum NetworkError: LocalizedError {
    case invalidURL
    case noInternetConnection
    case requestTimeout
    case serverError(statusCode: Int)
    case decodingError(Error)
    case unknownError(Error)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid. Please try again."
        case .noInternetConnection:
            return "No internet connection. Please check your network settings."
        case .requestTimeout:
            return "The request timed out. Please try again."
        case .serverError(let statusCode):
            return "Server error occurred (Status: \(statusCode)). Please try again later."
        case .decodingError:
            return "Failed to process the data. Please try again."
        case .unknownError:
            return "An unexpected error occurred. Please try again."
        case .noData:
            return "No data received from server."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noInternetConnection:
            return "Connect to Wi-Fi or cellular data and try again."
        case .serverError:
            return "The server might be experiencing issues. Try again in a few moments."
        case .requestTimeout:
            return "Check your internet connection and try again."
        default:
            return "Pull to refresh to try again."
        }
    }
}

/// Custom error types for local storage operations
enum StorageError: LocalizedError {
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    case contextNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save data locally."
        case .fetchFailed:
            return "Failed to retrieve local data."
        case .deleteFailed:
            return "Failed to delete local data."
        case .contextNotAvailable:
            return "Database context is not available."
        }
    }
    
    var recoverySuggestion: String? {
        return "Try restarting the app or clearing the app's data."
    }
}

/// Error types for business logic operations
enum DomainError: LocalizedError {
    case invalidPokemonData
    case pokemonNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidPokemonData:
            return "Invalid Pokemon data received."
        case .pokemonNotFound:
            return "Pokemon not found."
        }
    }
}
