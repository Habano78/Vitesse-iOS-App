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
        
        // MARK: - Properties
        
        private nonisolated let urlSession: URLSessionProtocol
        
        private let jsonEncoder: JSONEncoder
        private let jsonDecoder: JSONDecoder
        
        private let baseURL = URL(string: "http://127.0.0.1:8080")!
        
        // MARK: - Initialization
        
        init(urlSession: URLSessionProtocol = URLSession.shared) {
                self.urlSession = urlSession
                self.jsonEncoder = JSONEncoder()
                self.jsonDecoder = JSONDecoder()
        }
        
        // MARK: - AuthenticationServiceProtocol Conformance
        
        func login(credentials: AuthRequestDTO) async throws -> AuthResponseDTO {
                // Construction du endpoint(URL)
                let endpointURL = baseURL.appendingPathComponent("user/auth")
                
                // Création et configuration de la requête 
                var request = URLRequest(url: endpointURL)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                // 3. Essayer d'encoder le corps de la requête.
                do {
                        request.httpBody = try jsonEncoder.encode(credentials)
                } catch {
                        throw APIServiceError.requestEncodingFailed(error)
                }
                
                // 4. Exécuter l'appel réseau
                let data: Data
                let response: URLResponse
                
                do {
                        (data, response) = try await urlSession.data(for: request)
                } catch {
                        throw APIServiceError.networkError(error)
                }
                
                // 5. Valider la réponse HTTP
                guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIServiceError.unexpectedStatusCode(-1) // Cas improbable
                }
                
                guard httpResponse.statusCode != 401 && httpResponse.statusCode != 403 else {
                        throw APIServiceError.invalidCredentials
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                        throw APIServiceError.unexpectedStatusCode(httpResponse.statusCode)
                }
                
                // 6. Décoder la réponse JSON
                do {
                        let authResponse = try jsonDecoder.decode(AuthResponseDTO.self, from: data)
                        return authResponse
                } catch {
                        throw APIServiceError.responseDecodingFailed(error)
                }
        }
}
