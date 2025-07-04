//
//  RegisterViewModelTests.swift
//  VitesseTests
//
//  Created by Perez William on 04/07/2025.
//

import Testing
@testable import Vitesse

@MainActor
struct RegisterViewModelTests {
        
        @Test("Vérifie que le service est appelé et que le succès est signalé lors d'une inscription valide")
        func testRegister_succeeds_whenDataIsValid() async {
                // Arrange
                let mockAuthService = MockAuthService()
                mockAuthService.registerResult = .success(())
                
                var wasSuccessCallbackCalled = false
                let viewModel = RegisterViewModel(
                        authService: mockAuthService,
                        onRegisterSucceed: {
                                wasSuccessCallbackCalled = true
                        }
                )
                
                viewModel.firstName = "Test"
                viewModel.lastName = "User"
                viewModel.email = "test@user.com"
                viewModel.password = "password123"
                viewModel.confirmPassword = "password123"
                
                // Act
                await viewModel.register()
                
                // Assert
                #expect(wasSuccessCallbackCalled == true)
                #expect(viewModel.errorMessage == nil)
                #expect(mockAuthService.registerCallCount == 1)
        }
        
        @Test("Vérifie que le service n'est pas appelé si les mots de passe ne correspondent pas")
        func testRegister_fails_whenPasswordsDoNotMatch() async {
                // Arrange
                let mockAuthService = MockAuthService()
                let viewModel = RegisterViewModel(authService: mockAuthService, onRegisterSucceed: {})
                
                viewModel.firstName = "Test"
                viewModel.lastName = "User"
                viewModel.email = "test@user.com"
                
                viewModel.password = "123"
                viewModel.confirmPassword = "456"
                
                // Act
                await viewModel.register()
                
                // Assert
                #expect(viewModel.errorMessage == "Les mots de passe ne correspondent pas.")
                #expect(mockAuthService.registerCallCount == 0, "Le service ne doit pas être appelé si la validation échoue.")
        }
}
