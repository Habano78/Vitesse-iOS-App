//
//  AuthServiceTests.swift
//  VitesseTests
//
//  Created by Perez William on 09/07/2025.
//
import Foundation
import Testing
@testable import Vitesse

struct AuthServiceTests {
        
        // MARK: - Tests pour la fonction LOGIN
        
        @Test("Login - Cas Succès (200 OK)")
        func testLogin_success() async throws {
                // Arrange
                let mockURLSession = MockURLSession()
                let sut = AuthService(urlSession: mockURLSession)
                let expectedResponse = AuthResponseDTO(isAdmin: false, token: "token123")
                
                mockURLSession.dataToReturn = try JSONEncoder().encode(expectedResponse)
                mockURLSession.responseToReturn = HTTPURLResponse(url: URL(string: "u.c")!, statusCode: 200, httpVersion: nil, headerFields: nil)
                
                // Act
                let actualResponse = try await sut.login(credentials: .init(email: "a", password: "b"))
                
                // Assert
                #expect(actualResponse == expectedResponse)
        }
        
        @Test("Login - Échec (401 Non Autorisé)")
        func testLogin_when401_throwsInvalidCredentials() async throws {
                // Arrange
                let mockURLSession = MockURLSession()
                let sut = AuthService(urlSession: mockURLSession)
                mockURLSession.responseToReturn = HTTPURLResponse(url: URL(string: "u.c")!, statusCode: 401, httpVersion: nil, headerFields: nil)
                mockURLSession.dataToReturn = Data()
                
                // Act & Assert
                await #expect(throws: APIServiceError.invalidCredentials) {
                        _ = try await sut.login(credentials: .init(email: "a", password: "b"))
                }
        }
        
        @Test("Login - Échec (500 Erreur Serveur)")
        func testLogin_when500_throwsUnexpectedStatusCode() async throws {
                // Arrange
                let mockURLSession = MockURLSession()
                let sut = AuthService(urlSession: mockURLSession)
                mockURLSession.responseToReturn = HTTPURLResponse(url: URL(string: "u.c")!, statusCode: 500, httpVersion: nil, headerFields: nil)
                mockURLSession.dataToReturn = Data()
                
                // Act & Assert
                await #expect(throws: APIServiceError.unexpectedStatusCode(500)) {
                        _ = try await sut.login(credentials: .init(email: "a", password: "b"))
                }
        }
        
        @Test("Login - Échec (Erreur Réseau)")
        func testLogin_whenNetworkError_throwsNetworkError() async {
                // Arrange
                let mockURLSession = MockURLSession()
                let sut = AuthService(urlSession: mockURLSession)
                mockURLSession.errorToThrow = TestNetworkError.connectionLost
                
                // Act & Assert
                do {
                        _ = try await sut.login(credentials: .init(email: "a", password: "b"))
                        // Si on arrive ici, la fonction n'a pas levé d'erreur, ce qui est un échec pour ce test.
                        Issue.record("La fonction login() aurait dû lever une erreur mais ne l'a pas fait.")
                } catch {
                        // La fonction a bien levé une erreur, comme attendu.
                        // Maintenant, on vérifie que c'est la bonne.
                        #expect(error is APIServiceError, "L'erreur doit être de type APIServiceError.")
                        
                        guard let apiError = error as? APIServiceError else {
                                // L'assertion ci-dessus a déjà vérifié cela, mais ce guard est une sécurité.
                                return
                        }
                        
                        // On vérifie que c'est bien le bon cas d'erreur.
                        guard case .networkError = apiError else {
                                Issue.record("Le cas d'erreur devrait être .networkError, mais c'est \(apiError).")
                                return
                        }
                }
        }
        
        // MARK: - Tests pour la fonction REGISTER
        
        @Test("Register - Cas Succès (201 Created)")
        func testRegister_success() async throws {
                // Arrange
                let mockURLSession = MockURLSession()
                let sut = AuthService(urlSession: mockURLSession)
                mockURLSession.responseToReturn = HTTPURLResponse(url: URL(string: "u.c")!, statusCode: 201, httpVersion: nil, headerFields: nil)
                mockURLSession.dataToReturn = Data()
                
                // Act & Assert
                try await sut.register(with: .init(email: "a", password: "b", firstName: "c", lastName: "d"))
        }
        
        @Test("Register - Échec (409 Conflit)")
        func testRegister_when409_throwsUnexpectedStatusCode() async throws {
                // Arrange
                let mockURLSession = MockURLSession()
                let sut = AuthService(urlSession: mockURLSession)
                mockURLSession.responseToReturn = HTTPURLResponse(url: URL(string: "u.c")!, statusCode: 409, httpVersion: nil, headerFields: nil)
                mockURLSession.dataToReturn = Data()
                
                // Act & Assert
                await #expect(throws: APIServiceError.unexpectedStatusCode(409)) {
                        _ = try await sut.register(with: .init(email: "a", password: "b", firstName: "c", lastName: "d"))
                }
        }
}
