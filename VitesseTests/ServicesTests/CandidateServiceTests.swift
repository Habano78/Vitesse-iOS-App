//
//  CandidateServiceTests.swift
//  VitesseTests
//
//  Created by Perez William on 09/07/2025.
//
// Fichier: VitesseTests/CandidateServiceTests.swift

import Foundation
import Testing
@testable import Vitesse

// MARK: - Début des Tests pour CandidateService

struct CandidateServiceTests {
        
        // MARK: - fetchCandidates()
        
        @Test("fetchCandidates en cas de succès doit retourner une liste de candidats")
        func testFetchCandidates_succeeds() async throws {
                // Arrange
                let mockURLSession = MockURLSession()
                let sut = CandidateService(urlSession: mockURLSession)
                let expectedCandidates = [CandidateResponseDTO(id: UUID(), firstName: "Marie", lastName: "Curie", email: "m@c.fr", phone: nil, note: nil, linkedinURL: nil, isFavorite: false)]
                mockURLSession.dataToReturn = try JSONEncoder().encode(expectedCandidates)
                mockURLSession.responseToReturn = HTTPURLResponse(url: URL(string: "u.c")!, statusCode: 200, httpVersion: nil, headerFields: nil)
                
                // Act
                let actualCandidates = try await sut.fetchCandidates()
                
                // Assert
                #expect(actualCandidates == expectedCandidates)
                #expect(mockURLSession.lastRequest?.httpMethod == "GET")
        }
        
        @Test("fetchCandidates en cas d'échec doit lever une erreur")
        func testFetchCandidates_fails() async throws {
                // Arrange
                let mockURLSession = MockURLSession()
                let sut = CandidateService(urlSession: mockURLSession)
                mockURLSession.responseToReturn = HTTPURLResponse(url: URL(string: "u.c")!, statusCode: 500, httpVersion: nil, headerFields: nil)
                mockURLSession.dataToReturn = Data()
                
                // Act & Assert
                await #expect(throws: APIServiceError.unexpectedStatusCode(500)) {
                        _ = try await sut.fetchCandidates()
                }
        }
        
        @Test("deleteCandidate en cas de succès doit se terminer sans erreur")
        func testDeleteCandidate_succeeds() async throws {
                // Arrange
                let mockURLSession = MockURLSession()
                let sut = CandidateService(urlSession: mockURLSession)
                mockURLSession.responseToReturn = HTTPURLResponse(url: URL(string: "u.c")!, statusCode: 204, httpVersion: nil, headerFields: nil)
                mockURLSession.dataToReturn = Data()
                let candidateID = UUID()
                
                // Act
                try await sut.deleteCandidate(id: candidateID)
                
                // Assert
                #expect(mockURLSession.lastRequest?.httpMethod == "DELETE")
                #expect(mockURLSession.lastRequest?.url?.absoluteString.contains(candidateID.uuidString) == true)
        }
        
        // MARK: - toggleFavoriteStatus()
        
        @Test("toggleFavoriteStatus en cas de succès doit retourner le candidat mis à jour")
        func testToggleFavoriteStatus_succeeds() async throws {
                // Arrange
                let mockURLSession = MockURLSession()
                let sut = CandidateService(urlSession: mockURLSession)
                let candidateID = UUID()
                let expectedCandidate = CandidateResponseDTO(id: candidateID, firstName: "Marie", lastName: "Curie", email: "m@c.fr", phone: nil, note: nil, linkedinURL: nil, isFavorite: true)
                mockURLSession.dataToReturn = try JSONEncoder().encode(expectedCandidate)
                mockURLSession.responseToReturn = HTTPURLResponse(url: URL(string: "u.c")!, statusCode: 200, httpVersion: nil, headerFields: nil)
                
                // Act
                let actualCandidate = try await sut.toggleFavoriteStatus(id: candidateID)
                
                // Assert
                #expect(actualCandidate == expectedCandidate)
                #expect(mockURLSession.lastRequest?.httpMethod == "PUT")
                #expect(mockURLSession.lastRequest?.url?.absoluteString.contains("\(candidateID.uuidString)/favorite") == true)
        }
        
        // MARK: - updateCandidate()
        
        @Test("updateCandidate en cas de succès doit retourner le candidat mis à jour")
        func testUpdateCandidate_succeeds() async throws {
                // Arrange
                let mockURLSession = MockURLSession()
                let sut = CandidateService(urlSession: mockURLSession)
                let candidateID = UUID()
                let payload = CandidatePayloadDTO(firstName: "Marie", lastName: "Skłodowska-Curie", email: "m@c.fr", phone: nil, note: nil, linkedinURL: nil)
                let expectedCandidate = CandidateResponseDTO(id: candidateID, firstName: "Marie", lastName: "Skłodowska-Curie", email: "m@c.fr", phone: nil, note: nil, linkedinURL: nil, isFavorite: true)
                mockURLSession.dataToReturn = try JSONEncoder().encode(expectedCandidate)
                mockURLSession.responseToReturn = HTTPURLResponse(url: URL(string: "u.c")!, statusCode: 200, httpVersion: nil, headerFields: nil)
                
                // Act
                let actualCandidate = try await sut.updateCandidate(id: candidateID, with: payload)
                
                // Assert
                #expect(actualCandidate == expectedCandidate)
                #expect(mockURLSession.lastRequest?.httpMethod == "PUT")
        }
        
        // MARK: - createCandidate()
        
        @Test("createCandidate en cas de succès doit retourner le nouveau candidat")
        func testCreateCandidate_succeeds() async throws {
                // Arrange
                let mockURLSession = MockURLSession()
                let sut = CandidateService(urlSession: mockURLSession)
                let payload = CandidatePayloadDTO(firstName: "Nouveau", lastName: "Candidat", email: "new@c.fr", phone: nil, note: nil, linkedinURL: nil)
                let expectedCandidate = CandidateResponseDTO(id: UUID(), firstName: "Nouveau", lastName: "Candidat", email: "new@c.fr", phone: nil, note: nil, linkedinURL: nil, isFavorite: false)
                mockURLSession.dataToReturn = try JSONEncoder().encode(expectedCandidate)
                mockURLSession.responseToReturn = HTTPURLResponse(url: URL(string: "u.c")!, statusCode: 201, httpVersion: nil, headerFields: nil) // 201 Created
                
                // Act
                let actualCandidate = try await sut.createCandidate(with: payload)
                
                // Assert
                #expect(actualCandidate == expectedCandidate)
                #expect(mockURLSession.lastRequest?.httpMethod == "POST")
                
                // Vérifions que le payload a bien été encodé dans le corps de la requête
                let sentData = try #require(mockURLSession.lastRequest?.httpBody)
                let sentPayload = try JSONDecoder().decode(CandidatePayloadDTO.self, from: sentData)
                #expect(sentPayload == payload)
        }
}
