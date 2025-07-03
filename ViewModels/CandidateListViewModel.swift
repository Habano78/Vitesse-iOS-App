//
//  CandidateListViewModel.swift
//  Vitesse
//
//  Created by Perez William on 01/07/2025.
//

import Foundation

@MainActor
class CandidateListViewModel: ObservableObject {
        
        //MARK: Propriétés d'État pour la Vue
        @Published var isLoading: Bool = false
        @Published var errorMessage: String?
        
        @Published var searchText: String = ""
        @Published var isFavoritesFilterActive: Bool = false
        
        @Published private var allCandidates: [Candidate] = []
        
        // MARK: - Propriété Calculée pour la Vue
        // Liste que la vue va réellement afficher qui dépend de `allCandidates` et `searchText`.
        var candidates: [Candidate] {
                
                var filteredCandidates = allCandidates/// on part de la liste complete
                
                if isFavoritesFilterActive {
                        filteredCandidates = filteredCandidates.filter { $0.isFavorite } /// Si favoris est actif, on réduit la liste.
                }
                
                if !searchText.isEmpty { /// si l'utilisateur tape dans la barre de recherche (pas vide)
                        filteredCandidates = filteredCandidates.filter { candidate in
                                candidate.firstName.localizedCaseInsensitiveContains(searchText) ||
                                candidate.lastName.localizedCaseInsensitiveContains(searchText)
                        }
                }
                return filteredCandidates
        }
        
        //MARK: Dépendances
        private let candidateService: CandidateServiceProtocol
        
        init(candidateService: CandidateServiceProtocol = CandidateService()) {
                self.candidateService = candidateService
        }
        
        //MARK: Actions
        func fetchCandidates() async {
                self.isLoading = true
                defer {self.isLoading = false}
                self.errorMessage = nil
                
                do {
                        // Appel au service pour récupérer les DTOs
                        let candidateDTOs = try await candidateService.fetchCandidates()
                        
                        // Transformer ("mapper") le tableau de DTObs en tableau de modèles métier
                        self.allCandidates = candidateDTOs.map { dto in
                                Candidate(from: dto)
                        }
                        
                } catch let error as APIServiceError {
                        // En cas d'erreur connue de notre service, on affiche la description localisée
                        self.errorMessage = error.localizedDescription
                } catch {
                        // En cas d'autre erreur inattendue
                        self.errorMessage = "Une erreur inattendue est survenue."
                }
        }
        
        //MARK: suppresion de candidats
        func deleteCandidate(at offsets: IndexSet) async {
                // On garde une copie de l'ID avant toute modification du tableau.
                let candidatesToDelete = offsets.map { allCandidates[$0] }
                
                // On supprime d'abord de la liste locale
                allCandidates.remove(atOffsets: offsets)
                
                // On parcourt les candidats à supprimer et on appelle l'API pour chacun.
                for candidate in candidatesToDelete {
                        do {
                                try await candidateService.deleteCandidate(id: candidate.id)
                        } catch {
                                self.errorMessage = "La suppression de \(candidate.firstName) a échoué. Erreur : \(error.localizedDescription)"
                        }
                }
        }
        
}

