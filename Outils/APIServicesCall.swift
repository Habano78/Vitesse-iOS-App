//
//  APIServicesCall.swift
//  VitesseTests
//
//  Created by Perez William on 06/07/2025.

//  Cette classe contient les dépendances partagées et la logique d'appel générique.

import Foundation

class APIService {
        
        private let urlSession: URLSessionProtocol
        private let tokenManager: AuthTokenPersistenceProtocol
        private let jsonDecoder: JSONDecoder
        private let jsonEncoder: JSONEncoder
        
        let baseURL = URL(string: "http://127.0.0.1:8080")!
        
        init(
                urlSession: URLSessionProtocol = URLSession.shared,
                tokenManager: AuthTokenPersistenceProtocol = AuthTokenPersistence()
        ) {
                self.urlSession = urlSession
                self.tokenManager = tokenManager
                self.jsonDecoder = JSONDecoder()
                self.jsonEncoder = JSONEncoder()
        }
        
        // CAS 1: Pour les appels qui attendent une réponse à décoder.
        func performRequest<T: Decodable>(
                to endpoint: String,
                method: HTTPMethod,
                payload: (any Encodable)? = nil,
                needsAuth: Bool = true
        ) async throws -> T {
                // Le coeur de la logique est dans la méthode privée.
                let (data, _) = try await performBaseRequest(to: endpoint, method: method, payload: payload, needsAuth: needsAuth)
                
                do {
                        // On décode la réponse en type T.
                        return try jsonDecoder.decode(T.self, from: data)
                } catch {
                        throw APIServiceError.responseDecodingFailed(error)
                }
        }
        
        // CAS 2: Pour les appels qui n'attendent PAS de réponse à décoder (DELETE, ou POST comme `register`).
        // La seule différence est qu'on ne décode rien à la fin.
        func performRequest(
                to endpoint: String,
                method: HTTPMethod,
                payload: (any Encodable)? = nil, // <-- LE CHANGEMENT IMPORTANT EST ICI
                needsAuth: Bool = true
        ) async throws {
                // On exécute la requête, mais on ignore la `data` retournée.
                _ = try await performBaseRequest(to: endpoint, method: method, payload: payload, needsAuth: needsAuth)
        }
        
        //  CŒUR DE LA LOGIQUE PARTAGÉE
        private func performBaseRequest(
                to endpoint: String,
                method: HTTPMethod,
                payload: (any Encodable)?,
                needsAuth: Bool
        ) async throws -> (Data, URLResponse) {
                
                let url = baseURL.appendingPathComponent(endpoint)
                var request = URLRequest(url: url)
                request.httpMethod = method.rawValue
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                if needsAuth {
                        guard let token = try tokenManager.retrieveToken() else {
                                throw APIServiceError.tokenInvalidOrExpired
                        }
                        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
                
                if let payload {
                        do {
                                request.httpBody = try jsonEncoder.encode(payload)
                        } catch {
                                throw APIServiceError.requestEncodingFailed(error)
                        }
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
                
                guard (200...299).contains(httpResponse.statusCode) else {
                        if httpResponse.statusCode == 401 { throw APIServiceError.tokenInvalidOrExpired }
                        throw APIServiceError.unexpectedStatusCode(httpResponse.statusCode)
                }
                
                return (data, response)
        }
}
