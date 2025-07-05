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
        
        // MARK: - Propriétés de Test
        
        var viewModel: CandidateDetailViewModel!
        var mockCandidateService: MockCandidateService!
        
        // MARK: - Setup
        
        // L'init est appelé avant chaque test, garantissant un environnement propre.
        init() {
                let initialCandidate = Candidate(from: .init(id: UUID(), firstName: "Marie", lastName: "Curie", email: "marie@curie.fr", phone: nil, note: nil, linkedinURL: nil, isFavorite: false))
                
                mockCandidateService = MockCandidateService()
                viewModel = CandidateDetailViewModel(
                        candidate: initialCandidate,
                        candidateService: mockCandidateService
                )
        }
        
        // Erreur générique pour tester les cas inattendus
        private struct GenericTestError: Error {}
        
        // MARK: - Scénarios de Test
        
        @Test("Mode Édition : Vérifie que l'édition est bien activée et les données copiées")
        func testStartEditing_populatesEditableProperties() {
                // Act : On déclenche l'action
                viewModel.startEditing()
                
                // Assert : On vérifie les résultats attendus
                #expect(viewModel.isEditing == true)
                #expect(viewModel.editableFirstName == viewModel.candidate.firstName)
        }
        
        @Test("Mode Édition : Vérifie que l'annulation fonctionne")
        func testCancelEditing_resetsEditingState() {
                // Arrange
                viewModel.startEditing()
                #expect(viewModel.isEditing == true) // Pré-condition
                
                // Act
                viewModel.cancelEditing()
                
                // Assert
                #expect(viewModel.isEditing == false)
        }
        
        @Test("Sauvegarde : Vérifie que la sauvegarde réussit et met à jour le modèle")
        func testSaveChanges_succeeds() async {
                // Arrange
                let updatedDTO = CandidateResponseDTO(id: viewModel.candidate.id, firstName: "Marie-Update", lastName: "Curie", email: "marie@curie.fr", phone: nil, note: nil, linkedinURL: nil, isFavorite: false)
                mockCandidateService.updateCandidateResult = .success(updatedDTO)
                
                viewModel.startEditing()
                viewModel.editableFirstName = "Marie-Update"
                
                // Act
                await viewModel.saveChanges()
                
                // Assert
                #expect(mockCandidateService.updateCandidateCallCount == 1)
                #expect(viewModel.candidate.firstName == "Marie-Update")
                #expect(viewModel.isEditing == false)
        }
        
        @Test("Sauvegarde : Vérifie la gestion d'une erreur API connue")
        func testSaveChanges_whenAPIFails_shouldSetErrorMessage() async {
                // Arrange
                let expectedError = APIServiceError.unexpectedStatusCode(500)
                mockCandidateService.updateCandidateResult = .failure(expectedError)
                viewModel.startEditing()
                
                // Act
                await viewModel.saveChanges()
                
                // Assert
                #expect(viewModel.isEditing == true) // On doit rester en mode édition
                #expect(viewModel.errorMessage == expectedError.localizedDescription)
        }
        
        @Test("Favoris : Vérifie que le statut de favori est bien basculé")
        func testToggleFavoriteStatus_succeeds() async {
                // Arrange
                #expect(viewModel.candidate.isFavorite == false) // Pré-condition
                
                let updatedFavoriteDTO = CandidateResponseDTO(id: viewModel.candidate.id, firstName: "Marie", lastName: "Curie", email: "marie@curie.fr", phone: nil, note: nil, linkedinURL: nil, isFavorite: true)
                mockCandidateService.toggleFavoriteResult = .success(updatedFavoriteDTO)
                
                // Act
                await viewModel.toggleFavoriteStatus()
                
                // Assert
                #expect(mockCandidateService.toggleFavoriteCallCount == 1)
                #expect(viewModel.candidate.isFavorite == true)
        }
        
        @Test("Favoris : Vérifie la gestion d'erreur si l'appel échoue")
        func testToggleFavorite_whenAPIFails_shouldNotChangeState() async {
                // Arrange
                let initialFavoriteStatus = viewModel.candidate.isFavorite
                mockCandidateService.toggleFavoriteResult = .failure(GenericTestError())
                
                // Act
                await viewModel.toggleFavoriteStatus()
                
                // Assert : Le statut ne doit pas avoir changé
                #expect(viewModel.candidate.isFavorite == initialFavoriteStatus)
        }
}
