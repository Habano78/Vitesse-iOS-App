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
        
        @Test("toggleFavoriteStatus gère une erreur et ne change pas l'état")
        func testToggleFavoriteStatus_fails() async {
                // Arrange
                let candidate = createCompleteCandidate()
                let mockService = MockCandidateService()
                let viewModel = CandidateDetailViewModel(candidate: candidate, isAdmin: true, candidateService: mockService)
                mockService.toggleFavoriteResult = .failure(GenericTestError())
                
                // Act
                await viewModel.toggleFavoriteStatus()
                
                // Assert
                #expect(candidate.isFavorite == false)
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
}
