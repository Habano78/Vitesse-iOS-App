//
//  ServicesProtocols.swift
//  Vitesse
//
//  Created by Perez William on 17/07/2025.
//

import Foundation

//MARK: Protocole qui définit la seule fonctionnalité de URLSession que les services utilisent : la méthode data(for:).
protocol URLSessionProtocol: Sendable {
        func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}


//MARK: Protocole qui définit les fonctionnalités d'authentification
protocol AuthenticationServiceProtocol {
        @MainActor
        func login(credentials: AuthRequestDTO) async throws -> AuthResponseDTO
        
        @MainActor
        func register(with details: UserRegisterRequestDTO) async throws
}

//MARK: Protocole qui définit l'ensemble des fonctionnalités liées aux candidats : récuperer, supprimer, changer le statut, mise àjour, création des candidats
protocol CandidateServiceProtocol {
        @MainActor
        func fetchCandidates() async throws -> [CandidateResponseDTO]
        
        @MainActor
        func deleteCandidate(id candidateID: UUID) async throws -> Void
        
        @MainActor
        func toggleFavoriteStatus(id candidateID: UUID) async throws -> CandidateResponseDTO
        
        @MainActor
        func updateCandidate(id candidateID: UUID, with payload: CandidatePayloadDTO) async throws -> CandidateResponseDTO
        
        @MainActor
        func createCandidate(with payload: CandidatePayloadDTO) async throws -> CandidateResponseDTO
}
