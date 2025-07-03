//
//  CandidateDetailViewModel.swift
//  Vitesse
//
//  Created by Perez William on 02/07/2025.
//

import Foundation
import SwiftUI

@MainActor
class CandidateDetailViewModel: ObservableObject {
        
        // MARK: - Propriétés Principales
        @Published var candidate: Candidate
        
        // MARK: - Propriétés d'état pour la vue
        @Published var isEditing: Bool = false
        @Published var isLoading: Bool = false
        @Published var errorMessage: String?
        
        //MARK: Propriétés d'édition (champs de text)
        @Published var editableFirstName: String = ""
        @Published var editableLastName: String = ""
        @Published var editableEmail: String = ""
        @Published var editablePhone: String = ""
        @Published var editableNote: String = ""
        @Published var editableLinkedinURL: String = ""
        
        // MARK: - Dépendance
        private let candidateService: CandidateServiceProtocol
        
        //MARK: init et injection de dépendance
        init(candidate: Candidate,
             candidateService: CandidateServiceProtocol = CandidateService()
        ) {
                self.candidate = candidate
                self.candidateService = candidateService
        }
        
        // MARK: Actions
        
        func startEditing() {
                self.isEditing = true
                self.editableFirstName = candidate.firstName
                self.editableLastName = candidate.lastName
                self.editableEmail = candidate.email
                self.editablePhone = candidate.phone ?? ""
                self.editableNote = candidate.note ?? ""
                self.editableLinkedinURL = candidate.linkedinURL ?? ""
        }
        
        /// Annule l'édition et revient au mode lecture.
        func cancelEditing() {
                self.isEditing = false
        }
        
        /// Sauvegarde les modifications via l'API.
        func saveChanges() async {
                isLoading = true
                errorMessage = nil
                defer { isLoading = false }
                
                // 1. Crée le "payload" (DTO) à partir des données éditées
                let payload = CandidatePayloadDTO(
                        firstName: editableFirstName,
                        lastName: editableLastName,
                        email: editableEmail,
                        phone: editablePhone.isEmpty ? nil : editablePhone,
                        note: editableNote.isEmpty ? nil : editableNote,
                        linkedinURL: editableLinkedinURL.isEmpty ? nil : editableLinkedinURL
                )
                
                do {
                        // 2. Appelle le service de mise à jour
                        let updatedCandidateDTO = try await candidateService.updateCandidate(id: candidate.id, with: payload)
                        
                        // 3. Met à jour le modèle principal avec la réponse du serveur
                        self.candidate = Candidate(from: updatedCandidateDTO)
                        
                        // 4. Quitte le mode édition
                        self.isEditing = false
                        
                } catch let error as APIServiceError {
                        self.errorMessage = error.localizedDescription
                } catch {
                        self.errorMessage = "Une erreur de sauvegarde inattendue est survenue."
                }
        }
        func toggleFavoriteStatus() async {
                do {
                        /// Appelle au service pour changer le statut favori
                        let updatedCandidateDTO = try await candidateService.toggleFavoriteStatus(id: candidate.id)
                        /// On met à jour le modèle métier local avec la réponse du serveur
                        self.candidate = Candidate(from: updatedCandidateDTO)
                        
                } catch {
                        // Gérer l'erreur si nécessaire
                        print("Erreur lors de la mise à jour du statut favori : \(error.localizedDescription)")
                }
        }
        
}
