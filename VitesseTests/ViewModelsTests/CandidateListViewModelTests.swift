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
        
        // Données de test
        let candidate1 = CandidateResponseDTO(id: UUID(), firstName: "Marie", lastName: "Curie", email: "marie@curie.fr", phone: nil, note: nil, linkedinURL: nil, isFavorite: true)
        let candidate2 = CandidateResponseDTO(id: UUID(), firstName: "Albert", lastName: "Einstein", email: "albert@einstein.de", phone: nil, note: nil, linkedinURL: nil, isFavorite: false)
        let candidate3 = CandidateResponseDTO(id: UUID(), firstName: "Isaac", lastName: "Newton", email: "isaac@newton.uk", phone: nil, note: nil, linkedinURL: nil, isFavorite: true)
        
        init() {
                // On initialise les mocks et le ViewModel dans l'init
                // car le nouveau framework Testing recrée la struct pour chaque test.
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
}
