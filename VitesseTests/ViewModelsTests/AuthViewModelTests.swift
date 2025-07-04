//
//  AuthViewModelTests.swift
//  VitesseTests
//
//  Created by Perez William on 04/07/2025.
//

import Testing
@testable import Vitesse

@MainActor
struct AuthViewModelTests {
        
        @Test("Vérifie que le callback de succès est appelé lors d'une connexion réussie")
        func testLogin_succeeds() async {
                // Arrange
                let mockAuthService = MockAuthService()
                mockAuthService.loginResult = .success(AuthResponseDTO(isAdmin: true, token: "fake-token"))
                
                var wasSuccessCallbackCalled = false
                let viewModel = AuthViewModel(
                        authService: mockAuthService,
                        onLoginSucceed: { _ in
                                wasSuccessCallbackCalled = true
                        }
                )
                
                // Act
                await viewModel.login()
                
                // Assert
                #expect(wasSuccessCallbackCalled == true, "Le callback de succès aurait dû être appelé.")
                #expect(viewModel.errorMessage == nil)
        }
        
        @Test("Vérifie que le message d'erreur est défini lors d'une connexion échouée")
        func testLogin_fails() async {
                // Arrange
                let mockAuthService = MockAuthService()
                mockAuthService.loginResult = .failure(APIServiceError.invalidCredentials)
                
                let viewModel = AuthViewModel(authService: mockAuthService, onLoginSucceed: { _ in })
                
                // Act
                await viewModel.login()
                
                // Assert
                #expect(viewModel.errorMessage == APIServiceError.invalidCredentials.localizedDescription)
        }
}
