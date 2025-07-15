//
//  CandidateListViewModelTests.swift
//  VitesseTests
//
//  Created by Perez William on 04/07/2025.
//
import Foundation
import Testing
@testable import Vitesse

@MainActor
struct CandidateListViewModelTests {
        
        var viewModel: CandidateListViewModel!
        var mockCandidateService: MockCandidateService!
        
        // Données pour le test
        let candidate1 = CandidateResponseDTO(id: UUID(), firstName: "Marie", lastName: "Curie", email: "marie@curie.fr", phone: nil, note: nil, linkedinURL: nil, isFavorite: true)
        let candidate2 = CandidateResponseDTO(id: UUID(), firstName: "Albert", lastName: "Einstein", email: "albert@einstein.de", phone: nil, note: nil, linkedinURL: nil, isFavorite: false)
        let candidate3 = CandidateResponseDTO(id: UUID(), firstName: "Isaac", lastName: "Newton", email: "isaac@newton.uk", phone: nil, note: nil, linkedinURL: nil, isFavorite: true)
        
        init() {
                mockCandidateService = MockCandidateService()
                viewModel = CandidateListViewModel(candidateService: mockCandidateService)
        }
        
        @Test("Vérifie que les candidats sont bien récupérés et mappés")
        func testFetchCandidates_succeeds() async {
                // Arrange
                mockCandidateService.fetchCandidatesResult = .success([candidate1, candidate2])
                
                // Act
                await viewModel.fetchCandidates()
                
                // Assert
                #expect(viewModel.candidates.count == 2)
                #expect(viewModel.candidates.first?.firstName == "Marie")
                #expect(viewModel.errorMessage == nil)
        }
        
        @Test("Vérifie que le filtrage par recherche fonctionne")
        func testSearchText_filtersList() async {
                // Arrange
                mockCandidateService.fetchCandidatesResult = .success([candidate1, candidate2, candidate3])
                await viewModel.fetchCandidates() // On charge les données initiales
                
                // Act
                viewModel.searchText = "einstein"
                
                // Assert
                #expect(viewModel.candidates.count == 1)
                #expect(viewModel.candidates.first?.lastName == "Einstein")
        }
        
        @Test("Vérifie que le filtrage par favoris fonctionne")
        func testFavoritesFilter_filtersList() async {
                // Arrange
                mockCandidateService.fetchCandidatesResult = .success([candidate1, candidate2, candidate3])
                await viewModel.fetchCandidates()
                
                // Act
                viewModel.isFavoritesFilterActive = true
                
                // Assert
                #expect(viewModel.candidates.count == 2)
                #expect(viewModel.candidates.contains(where: { $0.lastName == "Curie" }))
                #expect(viewModel.candidates.contains(where: { $0.lastName == "Newton" }))
        }
        
        @Test("Vérifie que la suppression appelle le service et met à jour la liste")
        func testDeleteCandidate() async {
                // Arrange
                mockCandidateService.fetchCandidatesResult = .success([candidate1, candidate2])
                await viewModel.fetchCandidates()
                
                #expect(viewModel.candidates.count == 2) // Vérification initiale
                
                // Act
                // On simule la suppression du premier élément (index 0)
                await viewModel.deleteCandidate(at: IndexSet(integer: 0))
                
                // Assert
                #expect(mockCandidateService.deleteCandidateCallCount == 1, "La fonction de suppression du service doit être appelée une fois.")
                #expect(mockCandidateService.receivedCandidateIDForDelete == candidate1.id)
                #expect(viewModel.candidates.count == 1, "Il ne devrait rester qu'un seul candidat dans la liste.")
                #expect(viewModel.candidates.first?.id == candidate2.id)
        }
        
        @Test("Vérifie l'erreur générique lors de l'échec de la récupération des candidats")
        func testFetchCandidates_whenUnknownErrorOccurs_shouldSetGenericErrorMessage() async {
                // Arrange
                ///erreur bidon
                struct GenericError: Error {}
                mockCandidateService.fetchCandidatesResult = .failure(GenericError())
                
                // Act
                await viewModel.fetchCandidates()
                
                // Assert
                #expect(viewModel.errorMessage == "Une erreur inattendue est survenue.")
        }
        
        @Test("Vérifie la gestion d'erreur lors de l'échec de la suppression")
        func testDeleteCandidate_whenAPIFails_shouldSetErrorMessage() async {
                // Arrange
                // On pré-charge le ViewModel avec des données.
                let candidateToFailDelete = CandidateResponseDTO(
                        id: UUID(),
                        firstName: "John",
                        lastName: "Doe",
                        email: "",
                        phone: nil,
                        note: nil,
                        linkedinURL: nil,
                        isFavorite: false)
                
                mockCandidateService.fetchCandidatesResult = .success([candidateToFailDelete])
                await viewModel.fetchCandidates()
                
                // On configure le mock pour que la suppression échoue.
                let expectedError = APIServiceError.unexpectedStatusCode(500)
                mockCandidateService.deleteCandidateResult = .failure(expectedError)
                
                // Act
                await viewModel.deleteCandidate(at: IndexSet(integer: 0))
                
                // Assert
                #expect(viewModel.errorMessage != nil)
                #expect(viewModel.errorMessage?.contains("La suppression de John a échoué") == true)
        }
        
        @Test("Vérifie la gestion d'une erreur API spécifique lors de la récupération des candidats")
        func testFetchCandidates_whenAPIServiceFails_shouldSetErrorMessage() async {
                // Arrange
                // On configure le mock pour qu'il échoue avec une erreur API connue
                let expectedError = APIServiceError.networkError(NSError(domain: "Test", code: -1))
                mockCandidateService.fetchCandidatesResult = .failure(expectedError)
                
                // Act
                await viewModel.fetchCandidates()
                
                // Assert
                #expect(viewModel.candidates.isEmpty == true)
                #expect(viewModel.errorMessage == expectedError.localizedDescription)
        }
        
        @Test("deleteSelectedCandidates doit supprimer les candidats et appeler le service")
        func testDeleteSelectedCandidates_succeeds() async {
                // Arrange
                mockCandidateService.fetchCandidatesResult = .success([candidate1, candidate2, candidate3])
                await viewModel.fetchCandidates()
                
                // On s'assure que l'état initial est correct
                #expect(viewModel.candidates.count == 3)
                
                let idsToDelete: Set<UUID> = [candidate1.id, candidate3.id]
                
                // On configure le mock pour que la suppression réussisse
                mockCandidateService.deleteCandidateResult = .success(())
                
                // Act
                await viewModel.deleteSelectedCandidates(ids: idsToDelete)
                
                // Assert
                #expect(viewModel.candidates.count == 1, "Il ne devrait rester qu'un seul candidat.")
                #expect(viewModel.candidates.first?.id == candidate2.id)
                #expect(mockCandidateService.deleteCandidateCallCount == 2, "Le service de suppression aurait dû être appelé 2 fois.")
                #expect(viewModel.errorMessage == nil)
        }
        
        
        @Test("deleteSelectedCandidates doit définir un message d'erreur en cas d'échec")
        func testDeleteSelectedCandidates_whenAPIFails_shouldSetErrorMessage() async {
                // Arrange
                mockCandidateService.fetchCandidatesResult = .success([candidate1, candidate2])
                await viewModel.fetchCandidates()
                
                let idsToDelete: Set<UUID> = [candidate1.id]
                
                // On configure le mock pour que la suppression échoue
                mockCandidateService.deleteCandidateResult = .failure(APIServiceError.unexpectedStatusCode(500))
                
                // Act
                await viewModel.deleteSelectedCandidates(ids: idsToDelete)
                
                // Assert
                #expect(viewModel.candidates.count == 1, "La liste UI doit être mise à jour même en cas d'échec.")
                #expect(viewModel.errorMessage == "La suppression d'au moins un candidat a échoué. Veuillez rafraîchir.")
        }
}
