//
//  AddCandidateViewModelTests.swift
//  VitesseTests
//
//  Created by Perez William on 09/07/2025.
//

import Testing
@testable import Vitesse
import Foundation


@MainActor
struct AddCandidateViewModelTests {
        
        // MARK: - Cas de Succès
        
        @Test("addCandidate avec des données valides doit appeler le service et le callback de succès")
        func testAddCandidate_withValidData_succeeds() async {
                // Arrange
                let mockCandidateService = MockCandidateService()
                var wasCallbackCalled = false
                var addedCandidate: Candidate?
                
                let sut = AddCandidateViewModel(
                        candidateService: mockCandidateService,
                        onCandidateAdded: { newCandidate in
                                wasCallbackCalled = true
                                addedCandidate = newCandidate
                        }
                )
                
                // On configure le mock pour qu'il retourne un succès
                let expectedResponse = CandidateResponseDTO(id: UUID(), firstName: "Nouveau", lastName: "Candidat", email: "new@test.com", phone: nil, note: nil, linkedinURL: nil, isFavorite: false)
                mockCandidateService.createCandidateResult = .success(expectedResponse)
                
                // On remplit le formulaire du ViewModel
                sut.firstName = "Nouveau"
                sut.lastName = "Candidat"
                sut.email = "new@test.com"
                
                // Act
                await sut.addCandidate()
                
                // Assert
                #expect(wasCallbackCalled == true, "Le callback de succès aurait dû être appelé.")
                #expect(addedCandidate != nil, "Un candidat aurait dû être passé au callback.")
                #expect(addedCandidate?.id == expectedResponse.id)
                #expect(mockCandidateService.createCandidateCallCount == 1, "Le service createCandidate aurait dû être appelé une fois.")
                #expect(sut.errorMessage == nil, "Il ne devrait pas y avoir de message d'erreur.")
        }
        
        // MARK: - Cas d'Échec
        
        @Test("addCandidate doit définir un message d'erreur si un champ obligatoire est vide")
        func testAddCandidate_withEmptyRequiredField_shouldSetErrorMessage() async {
                // Arrange
                let mockCandidateService = MockCandidateService()
                let sut = AddCandidateViewModel(candidateService: mockCandidateService, onCandidateAdded: { _ in })
                
                sut.firstName = "Nouveau"
                // Le nom de famille est laissé vide
                sut.lastName = ""
                sut.email = "new@test.com"
                
                // Act
                await sut.addCandidate()
                
                // Assert
                #expect(sut.errorMessage == "Le prénom, le nom et l'email sont obligatoires.")
                #expect(mockCandidateService.createCandidateCallCount == 0, "Le service ne doit pas être appelé si la validation échoue.")
        }
        
        @Test("addCandidate doit définir un message d'erreur si le format de l'email est invalide")
        func testAddCandidate_withInvalidEmailFormat_shouldSetErrorMessage() async {
                // Arrange
                let mockCandidateService = MockCandidateService()
                let sut = AddCandidateViewModel(candidateService: mockCandidateService, onCandidateAdded: { _ in })
                
                sut.firstName = "Nouveau"
                sut.lastName = "Candidat"
                sut.email = "email-invalide" // Email mal formaté
                
                // Act
                await sut.addCandidate()
                
                // Assert
                #expect(sut.errorMessage == "Veuillez corriger le format des champs obligatoires.")
                #expect(mockCandidateService.createCandidateCallCount == 0)
        }
        
        @Test("addCandidate doit définir un message d'erreur en cas d'échec de l'API")
        func testAddCandidate_whenAPIFails_shouldSetErrorMessage() async {
                // Arrange
                let mockCandidateService = MockCandidateService()
                var wasCallbackCalled = false
                
                let sut = AddCandidateViewModel(
                        candidateService: mockCandidateService,
                        onCandidateAdded: { _ in wasCallbackCalled = true }
                )
                
                // On configure le mock pour qu'il échoue
                let expectedError = APIServiceError.unexpectedStatusCode(500)
                mockCandidateService.createCandidateResult = .failure(expectedError)
                
                // On remplit le formulaire avec des données valides
                sut.firstName = "Nouveau"
                sut.lastName = "Candidat"
                sut.email = "new@test.com"
                
                // Act
                await sut.addCandidate()
                
                // Assert
                #expect(wasCallbackCalled == false, "Le callback de succès ne doit pas être appelé en cas d'échec.")
                #expect(sut.errorMessage == expectedError.localizedDescription)
        }
        
        // MARK: - Tests des Validateurs individuels
        
        @Test("validatePhone avec un format invalide doit définir phoneErrorMessage")
        func testValidatePhone_withInvalidFormat_shouldSetErrorMessage() {
                // Arrange
                let sut = AddCandidateViewModel(onCandidateAdded: { _ in })
                sut.phone = "123-abc"
                
                // Act
                sut.validatePhone()
                
                // Assert
                #expect(sut.phoneErrorMessage == "Le format du téléphone est invalide.")
        }
        
        @Test("validateEmail avec un format invalide doit définir emailErrorMessage")
        func testValidateEmail_withInvalidFormat_shouldSetErrorMessage() {
                // Arrange
                let sut = AddCandidateViewModel(onCandidateAdded: { _ in })
                sut.email = "email.invalide"
                
                // Act
                sut.validateEmail()
                
                // Assert
                #expect(sut.emailErrorMessage == "Le format de l'email est invalide.")
        }
}
