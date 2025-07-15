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
        
        // MARK: Propriété Calculée. Liste que la vue va réellement afficher qui dépend de `allCandidates` et `searchText`.
        var candidates: [Candidate] {
                
                var filteredCandidates = allCandidates
                
                if isFavoritesFilterActive {
                        filteredCandidates = filteredCandidates.filter { $0.isFavorite }
                }
                
                if !searchText.isEmpty {
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
                let candidatesToDelete = offsets.map { self.candidates[$0] }
                
                let idsToDelete = Set(candidatesToDelete.map { $0.id })
                self.allCandidates.removeAll { idsToDelete.contains($0.id) }
                
                var deletionErrors: [Error] = []
                
                await withTaskGroup(of: Error?.self) { group in
                        for candidate in candidatesToDelete {
                                group.addTask {
                                        do {
                                                try await self.candidateService.deleteCandidate(id: candidate.id)
                                                return nil
                                        } catch {
                                                return error
                                        }
                                }
                        }
                        
                        for await result in group {
                                if let error = result {
                                        deletionErrors.append(error)
                                }
                        }
                }
                
                if !deletionErrors.isEmpty {
                        // On construit le message que le test attend
                        let failedNames = candidatesToDelete.map { $0.firstName }.joined(separator: ", ")
                        self.errorMessage = "La suppression de \(failedNames) a échoué"
                }
        }
        
        //MARK: rajouter des candidats
        func addCandidateToList(_ candidate: Candidate) {
                // On insère le nouveau candidat au début de notre liste source
                allCandidates.insert(candidate, at: 0)
        }
        
        //MARK: fonction pour gérer la suppresion multiple lors de la vue édition
        func deleteSelectedCandidates(ids: Set<UUID>) async {
                allCandidates.removeAll { ids.contains($0.id) }
                
                var deletionErrors: [Error] = []
                
                await withTaskGroup(of: Error?.self) { group in
                        for id in ids {
                                group.addTask {
                                        do {
                                                try await self.candidateService.deleteCandidate(id: id)
                                                return nil // Succès, on ne retourne pas d'erreur
                                        } catch {
                                                print("La suppression de \(id) a échoué: \(error)")
                                                return error // Échec, on retourne l'erreur
                                        }
                                }
                        }
                        
                        // collecte tous les résultats du groupe
                        for await result in group {
                                if let error = result {
                                        deletionErrors.append(error)
                                }
                        }
                }
                
                if !deletionErrors.isEmpty {
                        self.errorMessage = "La suppression d'au moins un candidat a échoué. Veuillez rafraîchir."
                }
        }
}

