//
//  CandidatesService.swift
//  Vitesse
//
//  Created by Perez William on 01/07/2025.
//

import Foundation

//MARK: définition du protocol pour récuperer des candidats
protocol CandidateServiceProtocol {
        @MainActor
        func fetchCandidates() async throws -> [CandidateResponseDTO]
        
        @MainActor
        func deleteCandidate(id candidateID: UUID) async throws -> Void
        
        @MainActor
        func toggleFavoriteStatus(id candidateID: UUID) async throws -> CandidateResponseDTO
        
        @MainActor
        func updateCandidate(id candidateID: UUID, with payload: CandidatePayloadDTO) async throws -> CandidateResponseDTO
        
}

//MARK: Implémentation du contrat
class CandidateService: CandidateServiceProtocol {
        
        //MARK: Propriétés et dépendances
        private let baseURL = URL(string: "http://127.0.0.1:8080")!
        //
        private nonisolated let urlSession: URLSessionProtocol
        private let tokenManager: AuthTokenPersistenceProtocol
        //
        private let jsonDecoder: JSONDecoder
        private let jsonEncoder: JSONEncoder
        
        //MARK: initialisation
        init (
                urlSession: URLSessionProtocol = URLSession.shared,
                tokenManager: AuthTokenPersistenceProtocol = AuthTokenPersistence()
        ){
                self.urlSession = urlSession
                self.tokenManager = tokenManager
                self.jsonDecoder = JSONDecoder()
                self.jsonEncoder = JSONEncoder()
        }
        
        // MARK: - Recuperation de Candidates
        func fetchCandidates() async throws -> [CandidateResponseDTO] {
                
                // Récuperation du token
                guard let token = try tokenManager.retrieveToken() else {
                        
                        throw APIServiceError.tokenInvalidOrExpired
                }
                
                // Construire l'URL
                let endpointURL = baseURL
                        .appendingPathComponent("candidate")
                
                // Créer la requête
                var request = URLRequest(url: endpointURL)
                request.httpMethod = "GET"
                
                // Ajout du header d'autorisation avec le token
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                // Exécuter l'appel
                let data: Data
                let response: URLResponse
                
                do {
                        (data, response) = try await urlSession.data(for: request)
                } catch {
                        throw APIServiceError.networkError(error)
                }
                
                // Valider la réponse
                guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIServiceError.unexpectedStatusCode(-1)
                }
                
                // Si le token est mauvais, l'API répond 401.
                guard httpResponse.statusCode != 401 else {
                        throw APIServiceError.tokenInvalidOrExpired
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                        throw APIServiceError.unexpectedStatusCode(httpResponse.statusCode)
                }
                
                // Décoder la réponse (un tableau de candidats) et la retourner
                do {
                        let candidates = try jsonDecoder.decode([CandidateResponseDTO].self, from: data)
                        return candidates
                } catch {
                        throw APIServiceError.responseDecodingFailed(error)
                }
        }
        
        //MARK: Suppresion de candidats
        func deleteCandidate(id candidateID: UUID) async throws -> Void {
                
                //Recuperation du token
                guard let token = try tokenManager.retrieveToken() else {
                        throw APIServiceError.tokenInvalidOrExpired
                }
                
                // Construction de l'URL complète avec endpoint
                let endpointURL = baseURL
                        .appendingPathComponent("candidate")
                        .appendingPathComponent(candidateID.uuidString)
                
                // Créer et configurer la requête
                var request = URLRequest(url: endpointURL)
                request.httpMethod = "DELETE"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                // Exécuter l'appel
                let (_, response) = try await urlSession.data(for: request)
                
                // Valider la réponse
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                        // Gérer le cas où le token serait invalide ou une autre erreur serveur
                        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                                throw APIServiceError.tokenInvalidOrExpired
                        }
                        throw APIServiceError.unexpectedStatusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
                }
        }
        
        //MARK: Changement à favoris
        func toggleFavoriteStatus(id candidateID: UUID) async throws -> CandidateResponseDTO {
                /// Autorisation nécessaire : récupération du token
                guard let token = try tokenManager.retrieveToken() else {
                        throw APIServiceError.tokenInvalidOrExpired
                }
                
                // Construction de l'URL complète avec endpoint
                let endpointURL = baseURL
                        .appendingPathComponent("candidate")
                        .appendingPathComponent(candidateID.uuidString)
                        .appendingPathComponent("favorite")
                
                // Créer et configurer la requête
                var request = URLRequest(url: endpointURL)
                request.httpMethod = "PUT" // La méthode pour mettre à jour est PUT
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                // Exécuter l'appel réseau
                let (data, response) = try await urlSession.data(for: request)
                
                // Valider la réponse du serveur
                guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIServiceError.unexpectedStatusCode(-1)
                }
                
                guard httpResponse.statusCode != 401 else {
                        throw APIServiceError.tokenInvalidOrExpired
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                        throw APIServiceError.unexpectedStatusCode(httpResponse.statusCode)
                }
                
                // Décoder le candidat mis à jour et le retourner
                do {
                        let updatedCandidate = try jsonDecoder.decode(CandidateResponseDTO.self, from: data)
                        return updatedCandidate
                } catch {
                        throw APIServiceError.responseDecodingFailed(error)
                }
        }
        
        //MARK: mise à jour des candidats
        func updateCandidate(id candidateID: UUID, with payload: CandidatePayloadDTO) async throws -> CandidateResponseDTO {
                // 1. Récupérer le token pour l'autorisation
                guard let token = try tokenManager.retrieveToken() else {
                        throw APIServiceError.tokenInvalidOrExpired
                }
                
                // Construire URL
                let endpointURL = baseURL
                        .appendingPathComponent("candidate")
                        .appendingPathComponent(candidateID.uuidString)
                
                // Créer requête
                var request = URLRequest(url: endpointURL)
                request.httpMethod = "PUT"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                // Encoder corps de requête
                do {
                        request.httpBody = try jsonEncoder.encode(payload)
                } catch {
                        throw APIServiceError.requestEncodingFailed(error)
                }
                
                // Exécuter l'appel
                let (data, response) = try await urlSession.data(for: request)
                
                // Valider la réponse
                guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIServiceError.unexpectedStatusCode(-1)
                }
                
                guard httpResponse.statusCode != 401 else {
                        throw APIServiceError.tokenInvalidOrExpired
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                        throw APIServiceError.unexpectedStatusCode(httpResponse.statusCode)
                }
                
                // Décoder le candidat mis à jour et le retourner
                do {
                        let updatedCandidate = try jsonDecoder.decode(CandidateResponseDTO.self, from: data)
                        return updatedCandidate
                } catch {
                        throw APIServiceError.responseDecodingFailed(error)
                }
        }
}
