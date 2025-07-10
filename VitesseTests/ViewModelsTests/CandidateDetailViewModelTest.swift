//
//  CandidateDetailListViewModelTest.swift
//  VitesseTests
//
//  Created by Perez William on 04/07/2025.
//
import Foundation
import Testing
@testable import Vitesse

@MainActor
struct CandidateDetailViewModelTests {
        
        // MARK: - Helpers
        
        private func createCompleteCandidate() -> Candidate {
                let dto = CandidateResponseDTO(id: UUID(), firstName: "Marie", lastName: "Curie", email: "marie@curie.fr", phone: "0123456789", note: "Note initiale", linkedinURL: "linkedin.com/marie", isFavorite: false)
                return Candidate(from: dto)
        }
        
        private func createCandidateWithNilValues() -> Candidate {
                let dto = CandidateResponseDTO(id: UUID(), firstName: "John", lastName: "Doe", email: "john@doe.com", phone: nil, note: nil, linkedinURL: nil, isFavorite: false)
                return Candidate(from: dto)
        }
        
        private struct GenericTestError: Error {}
        
        // MARK: - Tests pour startEditing() et cancelEditing()
        
        @Test("startEditing doit copier les valeurs et gérer les nils")
        func testStartEditing() {
                // Arrange
                let vmWithValues = CandidateDetailViewModel(candidate: createCompleteCandidate(), isAdmin: true)
                let vmWithNil = CandidateDetailViewModel(candidate: createCandidateWithNilValues(), isAdmin: true)
                
                // Act
                vmWithValues.startEditing()
                vmWithNil.startEditing()
                
                // Assert
                #expect(vmWithValues.isEditing == true)
                #expect(vmWithValues.editablePhone == "0123456789")
                #expect(vmWithNil.editablePhone == "") // Test du ?? ""
        }
        
        @Test("cancelEditing doit désactiver le mode édition")
        func testCancelEditing() {
                // Arrange
                let viewModel = CandidateDetailViewModel(candidate: createCompleteCandidate(), isAdmin: true)
                viewModel.startEditing()
                
                // Act
                viewModel.cancelEditing()
                
                // Assert
                #expect(viewModel.isEditing == false)
        }
        
        // MARK: - Tests pour saveChanges()
        
        @Test("saveChanges doit réussir et mettre à jour le modèle")
        func testSaveChanges_succeeds() async {
                // Arrange
                let candidate = createCompleteCandidate()
                let mockService = MockCandidateService()
                let viewModel = CandidateDetailViewModel(candidate: candidate, isAdmin: true, candidateService: mockService)
                
                let updatedDTO = CandidateResponseDTO(
                        id: candidate.id,
                        firstName: "Marie-Updated",
                        lastName: "Curie",
                        email: candidate.email,
                        phone: candidate.phone,
                        note: "Note mise à jour",
                        linkedinURL: candidate.linkedinURL,
                        isFavorite: candidate.isFavorite
                )
                mockService.updateCandidateResult = .success(updatedDTO)
                
                viewModel.startEditing()
                
                // Act
                await viewModel.saveChanges()
                
                // Assert
                #expect(mockService.updateCandidateCallCount == 1)
                #expect(viewModel.isEditing == false)
                #expect(viewModel.errorMessage == nil)
        }
        
        @Test("saveChanges gère une erreur API spécifique")
        func testSaveChanges_whenAPIFails_setsErrorMessage() async {
                // Arrange
                let mockService = MockCandidateService()
                let viewModel = CandidateDetailViewModel(candidate: createCompleteCandidate(), isAdmin: true, candidateService: mockService)
                let expectedError = APIServiceError.unexpectedStatusCode(500)
                mockService.updateCandidateResult = .failure(expectedError)
                
                viewModel.startEditing()
                
                // Act
                await viewModel.saveChanges()
                
                // Assert
                #expect(viewModel.isEditing == true)
                #expect(viewModel.errorMessage == expectedError.localizedDescription)
        }
        
        @Test("saveChanges gère une erreur inconnue")
        func testSaveChanges_whenUnknownErrorOccurs_setsGenericErrorMessage() async {
                // Arrange
                let mockService = MockCandidateService()
                let viewModel = CandidateDetailViewModel(candidate: createCompleteCandidate(), isAdmin: true, candidateService: mockService)
                mockService.updateCandidateResult = .failure(GenericTestError())
                
                viewModel.startEditing()
                
                // Act
                await viewModel.saveChanges()
                
                // Assert
                #expect(viewModel.errorMessage == "Une erreur de sauvegarde inattendue est survenue.")
        }
        
        // MARK: - Tests pour toggleFavoriteStatus()
        
        @Test("toggleFavoriteStatus réussit et met à jour le modèle")
        func testToggleFavoriteStatus_succeeds() async {
                // Arrange
                let candidate = createCompleteCandidate()
                let mockService = MockCandidateService()
                let viewModel = CandidateDetailViewModel(candidate: candidate, isAdmin: true, candidateService: mockService)
                
                var updatedDTO = CandidateResponseDTO(
                        id: candidate.id,
                        firstName: candidate.firstName,
                        lastName: candidate.lastName,
                        email: candidate.email,
                        phone: candidate.phone,
                        note: candidate.note,
                        linkedinURL: candidate.linkedinURL,
                        isFavorite: false
                )
                updatedDTO.isFavorite = true
                mockService.toggleFavoriteResult = .success(updatedDTO)
                
                // Act
                await viewModel.toggleFavoriteStatus()
                
                // Assert
                #expect(viewModel.candidate.isFavorite == true)
        }
        
        @Test("Vérifie que le statut isAdmin est correctement initialisé")
        func testIsAdmin_isCorrectlySet() {
                // Arrange
                let candidate = createCompleteCandidate()
                
                // Act
                let adminViewModel = CandidateDetailViewModel(candidate: candidate, isAdmin: true)
                let nonAdminViewModel = CandidateDetailViewModel(candidate: candidate, isAdmin: false)
                
                // Assert
                #expect(adminViewModel.isAdmin == true, "Le ViewModel admin doit avoir isAdmin = true")
                #expect(nonAdminViewModel.isAdmin == false, "Le ViewModel non-admin doit avoir isAdmin = false")
        }
        
        @Test("toggleFavoriteStatus doit définir un message d'erreur en cas d'échec de l'API")
        func testToggleFavoriteStatus_whenAPIFails_shouldSetErrorMessage() async {
                // Arrange
                let mockService = MockCandidateService()
                let initialCandidate = createCompleteCandidate()
                let viewModel = CandidateDetailViewModel(candidate: initialCandidate, isAdmin: true, candidateService: mockService)
                
                // On configure le mock pour qu'il échoue avec une erreur spécifique
                let expectedError = APIServiceError.tokenInvalidOrExpired
                mockService.toggleFavoriteResult = .failure(expectedError)
                
                // Act
                await viewModel.toggleFavoriteStatus()
                
                // Assert
                #expect(viewModel.errorMessage == expectedError.localizedDescription)
                #expect(viewModel.candidate.isFavorite == initialCandidate.isFavorite)
        }
        @Test("validatePhone doit définir une erreur si le numéro contient des lettres")
        func testValidatePhone_withInvalidFormat_shouldSetErrorMessage() {
                // Arrange
                let viewModel = CandidateDetailViewModel(candidate: createCompleteCandidate(), isAdmin: true)
                
                // Act
                viewModel.editablePhone = "0123ABC789" // Numéro invalide
                viewModel.validatePhone()
                
                // Assert
                #expect(viewModel.phoneErrorMessage == "Le format du téléphone est invalide (chiffres uniquement).")
        }
        
        @Test("validateEmail doit définir une erreur si l'email est mal formaté")
        func testValidateEmail_withInvalidFormat_shouldSetErrorMessage() {
                // Arrange
                let viewModel = CandidateDetailViewModel(candidate: createCompleteCandidate(), isAdmin: true)
                
                // Act
                viewModel.editableEmail = "marie@curie" // Email invalide (manque le .fr)
                viewModel.validateEmail()
                
                // Assert
                #expect(viewModel.emailErrorMessage == "Le format de l'email est invalide.")
        }
        
        @Test("toggleFavoriteStatus doit gérer une erreur inconnue et afficher un message générique")
        func testToggleFavoriteStatus_withUnknownError_setsGenericErrorMessage() async {
                // Arrange
                struct ErrorBidon: Error {}
                let candidate = createCompleteCandidate()
                let mockService = MockCandidateService()
                mockService.toggleFavoriteResult = .failure(ErrorBidon())
                let viewModel = CandidateDetailViewModel(candidate: candidate, isAdmin: true, candidateService: mockService)
                
                // Act
                await viewModel.toggleFavoriteStatus()
                
                // Assert
                #expect(viewModel.errorMessage == "Une erreur inattendue est survenue.")
        }
        
        @Test("saveChanges ne doit pas continuer si les champs sont invalides")
        func testSaveChanges_withValidationErrors_shouldBlockSave() async {
                // Arrange
                let mockService = MockCandidateService()
                let viewModel = CandidateDetailViewModel(candidate: createCompleteCandidate(), isAdmin: true, candidateService: mockService)
                
                viewModel.startEditing()
                viewModel.editablePhone = "123ABC" // mauvais format → déclenche phoneErrorMessage
                viewModel.editableEmail = "invalidemail" // mauvais format → déclenche emailErrorMessage
                viewModel.validatePhone()
                viewModel.validateEmail()
                
                // Act
                await viewModel.saveChanges()
                
                // Assert
                #expect(viewModel.errorMessage == "Veuillez corriger les erreurs avant de sauvegarder.")
                #expect(mockService.updateCandidateCallCount == 0, "Le service ne doit pas être appelé si validation échoue.")
        }
        
}
