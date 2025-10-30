//
//  NetworkClient.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//

import Foundation

protocol NetworkClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T
}

final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    /// Performs a network request and decodes the response
    /// - Parameters:
    ///   - endpoint: API endpoint to call
    ///   - responseType: Expected response type conforming to Decodable
    /// - Returns: Decoded response object
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        let request = try endpoint.makeRequest()
        
        do {
            let (data, response) = try await session.data(for: request)
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknownError(NSError(domain: "Invalid response", code: -1))
            }
            
            // Check status code
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }
            
            // Validate data
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            
            // Decode response
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                return decodedData
            } catch {
                throw NetworkError.decodingError(error)
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            // Handle URLSession errors
            if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.noInternetConnection
            } else if (error as NSError).code == NSURLErrorTimedOut {
                throw NetworkError.requestTimeout
            } else {
                throw NetworkError.unknownError(error)
            }
        }
    }
}

// MARK: - Mock for Testing

#if DEBUG
final class MockNetworkClient: NetworkClientProtocol {
    var mockResponse: Any?
    var shouldFail: Bool = false
    var errorToThrow: Error = NetworkError.unknownError(NSError(domain: "Mock", code: -1))
    
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        if shouldFail {
            throw errorToThrow
        }
        
        guard let response = mockResponse as? T else {
            throw NetworkError.decodingError(NSError(domain: "Mock decode error", code: -1))
        }
        
        return response
    }
}
#endif
