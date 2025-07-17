//
//  CandidatesService.swift
//  Vitesse
//
//  Created by Perez William on 01/07/2025.
//

import Foundation


//MARK: Implémentation des contrats
class CandidateService: APIService, CandidateServiceProtocol {
        
        // L'initialiseur appelle la classe mère. Les dépendances sont maintenant gérées par APIService.
        func fetchCandidates() async throws -> [CandidateResponseDTO] {
                try await performRequest(to: "candidate", method: .GET)
        }
        
        func deleteCandidate(id candidateID: UUID) async throws {
                let endpoint = "candidate/\(candidateID.uuidString)"
                // On utilise la version qui ne retourne rien
                try await performRequest(to: endpoint, method: .DELETE)
        }
        
        func toggleFavoriteStatus(id candidateID: UUID) async throws -> CandidateResponseDTO {
                let endpoint = "candidate/\(candidateID.uuidString)/favorite"
                return try await performRequest(to: endpoint, method: .PUT)
        }
        
        func updateCandidate(id candidateID: UUID, with payload: CandidatePayloadDTO) async throws -> CandidateResponseDTO {
                let endpoint = "candidate/\(candidateID.uuidString)"
                return try await performRequest(to: endpoint, method: .PUT, payload: payload)
        }
        
        func createCandidate(with payload: CandidatePayloadDTO) async throws -> CandidateResponseDTO {
                // L'API attend une requête POST sur l'endpoint "candidate"
                // et retourne le candidat nouvellement créé.
                return try await performRequest(to: "candidate", method: .POST, payload: payload)
        }
}
