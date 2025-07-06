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
        
        @Test("Vérifie que le callback de succès est appelé lors d'une inscription valide")
        func testRegister_succeeds() async {
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
                #expect(mockAuthService.receivedRegistrationDetails?.email == "test@user.com")
        }
        
        @Test("Vérifie l'erreur quand les mots de passe ne correspondent pas")
        func testRegister_whenPasswordsDoNotMatch_shouldSetErrorMessage() async {
                // Arrange
                let mockAuthService = MockAuthService()
                let viewModel = RegisterViewModel(authService: mockAuthService, onRegisterSucceed: {})
                
                // On remplit tous les champs pour passer la première validation
                viewModel.firstName = "Test"
                viewModel.lastName = "User"
                viewModel.email = "test@user.com"
                viewModel.password = "123"
                viewModel.confirmPassword = "456" // Mots de passe différents
                
                // Act
                await viewModel.register()
                
                // Assert
                #expect(viewModel.errorMessage == "Les mots de passe ne correspondent pas.")
                #expect(mockAuthService.registerCallCount == 0)
        }
        
        @Test("Vérifie l'erreur quand un champ est vide")
        func testRegister_whenFieldIsEmpty_shouldSetErrorMessage() async {
                // Arrange
                let mockAuthService = MockAuthService()
                let viewModel = RegisterViewModel(authService: mockAuthService, onRegisterSucceed: {})
                
                viewModel.firstName = "Test" // On laisse les autres champs vides
                
                // Act
                await viewModel.register()
                
                // Assert
                #expect(viewModel.errorMessage == "Tous les champs sont obligatoires.")
                #expect(mockAuthService.registerCallCount == 0)
        }
        
        // ... à l'intérieur de la struct RegisterViewModelTests ...
        
        // On peut définir une erreur générique pour nos tests
        private struct GenericTestError: Error {}
        
        @Test("Vérifie la gestion d'une erreur API spécifique lors de l'inscription")
        func testRegister_whenAPIServiceFails_shouldSetSpecificErrorMessage() async {
                // Arrange
                let mockAuthService = MockAuthService()
                // On configure le mock pour qu'il échoue avec une erreur API connue
                let expectedError = APIServiceError.unexpectedStatusCode(409) // 409 Conflict (ex: email déjà utilisé)
                mockAuthService.registerResult = .failure(expectedError)
                
                let viewModel = RegisterViewModel(authService: mockAuthService, onRegisterSucceed: {})
                
                // On remplit le formulaire avec des données valides pour passer la validation initiale
                viewModel.firstName = "John"
                viewModel.lastName = "Doe"
                viewModel.email = "john@doe.com"
                viewModel.password = "password123"
                viewModel.confirmPassword = "password123"
                
                // Act
                await viewModel.register()
                
                // Assert
                #expect(viewModel.errorMessage == expectedError.localizedDescription)
        }
        
        @Test("Vérifie la gestion d'une erreur inconnue lors de l'inscription")
        func testRegister_whenUnknownErrorOccurs_shouldSetGenericErrorMessage() async {
                // Arrange
                let mockAuthService = MockAuthService()
                // On configure le mock pour qu'il échoue avec une erreur non-spécifique
                mockAuthService.registerResult = .failure(GenericTestError())
                
                let viewModel = RegisterViewModel(authService: mockAuthService, onRegisterSucceed: {})
                
                // On remplit le formulaire avec des données valides
                viewModel.firstName = "Jane"
                viewModel.lastName = "Doe"
                viewModel.email = "jane@doe.com"
                viewModel.password = "password123"
                viewModel.confirmPassword = "password123"
                
                // Act
                await viewModel.register()
                
                // Assert
                #expect(viewModel.errorMessage == "Une erreur d'inscription inattendue est survenue.")
        }
}
