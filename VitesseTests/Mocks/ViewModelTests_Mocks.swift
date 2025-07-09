//
//  MocksForTests.swift
//  VitesseTests
//
//  Created by Perez William on 04/07/2025.
//
import Foundation
@testable import Vitesse

// MARK: - MockAuthTokenPersistence
// Simule la sauvegarde et la récupération du token en mémoire.
class MockAuthTokenPersistence: AuthTokenPersistenceProtocol {
        var storedToken: String?
        
        func saveToken(_ token: String) throws { storedToken = token }
        func retrieveToken() throws -> String? { return storedToken }
        func deleteToken() throws { storedToken = nil }
}


// MARK: - MockAuthService
// Simule les services d'authentification et d'inscription.
class MockAuthService: AuthenticationServiceProtocol {
        
        // MARK: - Propriétés de Contrôle
        var loginResult: Result<AuthResponseDTO, Error> = .success(.init(isAdmin: true, token: "fake-token"))
        var registerResult: Result<Void, Error> = .success(())
        
        // MARK: - Propriétés "Espions"
        var loginCallCount = 0
        var registerCallCount = 0
        var receivedCredentials: AuthRequestDTO?
        var receivedRegistrationDetails: UserRegisterRequestDTO?
        
        // MARK: - Implémentation du Protocole
        @MainActor
        func login(credentials: AuthRequestDTO) async throws -> AuthResponseDTO {
                loginCallCount += 1
                receivedCredentials = credentials
                return try loginResult.get()
        }
        
        @MainActor
        func register(with details: UserRegisterRequestDTO) async throws {
                registerCallCount += 1
                receivedRegistrationDetails = details
                try registerResult.get()
        }
}

// MARK: - MockCandidateService
// Simule le service de gestion des candidats
class MockCandidateService: CandidateServiceProtocol {
        
        // MARK: - Propriétés de Contrôle
        var fetchCandidatesResult: Result<[CandidateResponseDTO], Error> = .success([])
        var deleteCandidateResult: Result<Void, Error> = .success(())
        var toggleFavoriteResult: Result<CandidateResponseDTO, Error>?
        var updateCandidateResult: Result<CandidateResponseDTO, Error>?
        var createCandidateResult: Result<CandidateResponseDTO, Error>?
        
        // MARK: - Propriétés "Espions"
        var fetchCandidatesCallCount = 0
        var deleteCandidateCallCount = 0
        var toggleFavoriteCallCount = 0
        var updateCandidateCallCount = 0
        var createCandidateCallCount = 0
        
        var receivedCandidateIDForDelete: UUID?
        var receivedCandidateIDForToggle: UUID?
        var receivedCandidateIDForUpdate: UUID?
        var receivedPayloadForUpdate: CandidatePayloadDTO?
        var receivedPayloadForCreate: CandidatePayloadDTO?
        
        // MARK: - Implémentation du Protocole
        
        @MainActor
        func fetchCandidates() async throws -> [CandidateResponseDTO] {
                fetchCandidatesCallCount += 1
                return try fetchCandidatesResult.get()
        }
        
        @MainActor
        func deleteCandidate(id candidateID: UUID) async throws {
                deleteCandidateCallCount += 1
                receivedCandidateIDForDelete = candidateID
                try deleteCandidateResult.get()
        }
        
        @MainActor
        func toggleFavoriteStatus(id candidateID: UUID) async throws -> CandidateResponseDTO {
                toggleFavoriteCallCount += 1
                receivedCandidateIDForToggle = candidateID
                if let result = toggleFavoriteResult { return try result.get() }
                // Par défaut, on lance une erreur si aucun résultat n'est configuré pour ce test.
                throw APIServiceError.unexpectedStatusCode(500)
        }
        
        @MainActor
        func updateCandidate(id candidateID: UUID, with payload: CandidatePayloadDTO) async throws -> CandidateResponseDTO {
                updateCandidateCallCount += 1
                receivedCandidateIDForUpdate = candidateID
                receivedPayloadForUpdate = payload
                if let result = updateCandidateResult { return try result.get() }
                // Par défaut, on lance une erreur si aucun résultat n'est configuré.
                throw APIServiceError.unexpectedStatusCode(500)
        }
        @MainActor
        func createCandidate(with payload: CandidatePayloadDTO) async throws -> CandidateResponseDTO {
                createCandidateCallCount += 1
                receivedPayloadForCreate = payload
                
                if let result = createCandidateResult {
                        return try result.get()
                }
                
                // Par défaut, on lance une erreur si aucun résultat n'est configuré.
                throw APIServiceError.unexpectedStatusCode(500)
        }
        
}

//MARK: MOCK pour délibérément faire échouer l'encodeur et tester invalidURL
class MockJSONEncoder: JSONEncoderProtocol {
        
        struct MockEncodingError: Error {}
        
        var shouldThrowError = false
        
        func encode<T: Encodable>(_ value: T) throws -> Data {
                if shouldThrowError {
                        
                        throw MockEncodingError()
                }
                /// Si on ne doit pas échouer, on utilise le vrai encodeur pour retourner des données valides.
                return try JSONEncoder().encode(value)
        }
}
