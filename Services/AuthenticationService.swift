//
//  AuthService.swift
//  Vitesse
//
//  Created by Perez William on 30/06/2025.
//
import Foundation

// MARK: - Authentication Service Protocol
protocol AuthenticationServiceProtocol {
        @MainActor
        func login(credentials: AuthRequestDTO) async throws -> AuthResponseDTO
}

// MARK: - Authentication Service Implementation
class AuthService: AuthenticationServiceProtocol {
        
        // MARK: - Properties et dépendances
        private nonisolated let urlSession: URLSessionProtocol
        private let tokenManager: AuthTokenPersistenceProtocol
        
        private let jsonDecoder: JSONDecoder
        private let jsonEncoder: JSONEncoder
        
        private let baseURL = URL(string: "http://127.0.0.1:8080")!
        
        // MARK: - Init
        init(
                urlSession: URLSessionProtocol = URLSession.shared,
                tokenManager: AuthTokenPersistenceProtocol = AuthTokenPersistence()
        ) {
                self.urlSession = urlSession
                self.tokenManager = tokenManager
                self.jsonEncoder = JSONEncoder()
                self.jsonDecoder = JSONDecoder()
        }
        
        // MARK: - Authentication
        func login(credentials: AuthRequestDTO) async throws -> AuthResponseDTO {
                // ... (votre code existant pour le login reste ici, inchangé)
                let endpointURL = baseURL.appendingPathComponent("user/auth")
                var request = URLRequest(url: endpointURL)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                do {
                        request.httpBody = try jsonEncoder.encode(credentials)
                } catch {
                        throw APIServiceError.requestEncodingFailed(error)
                }
                
                let data: Data
                let response: URLResponse
                
                do {
                        (data, response) = try await urlSession.data(for: request)
                } catch {
                        throw APIServiceError.networkError(error)
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIServiceError.unexpectedStatusCode(-1)
                }
                
                guard httpResponse.statusCode != 401 && httpResponse.statusCode != 403 else {
                        throw APIServiceError.invalidCredentials
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                        throw APIServiceError.unexpectedStatusCode(httpResponse.statusCode)
                }
                
                do {
                        let authResponse = try jsonDecoder.decode(AuthResponseDTO.self, from: data)
                        return authResponse
                } catch {
                        throw APIServiceError.responseDecodingFailed(error)
                }
        }
}

