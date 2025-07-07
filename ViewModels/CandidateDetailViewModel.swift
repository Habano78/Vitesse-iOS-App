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
        
        // MARK: Propriété Principale
        @Published var candidate: Candidate
        
        // MARK: Propriétés d'état pour la vue
        @Published var isEditing: Bool = false
        @Published var isLoading: Bool = false
        @Published var errorMessage: String?
        @Published var phoneErrorMessage: String?
        @Published var emailErrorMessage: String?
        
        
        //MARK: Propriétés d'édition (champs de text)
        @Published var editableFirstName: String = ""
        @Published var editableLastName: String = ""
        @Published var editableEmail: String = ""
        @Published var editablePhone: String = ""
        @Published var editableNote: String = ""
        @Published var editableLinkedinURL: String = ""
        @Published var isTogglingFavorite: Bool = false
        
        //propriété pour notifier du statut admin
        let isAdmin: Bool
        
        // MARK: - Dépendance
        private let candidateService: CandidateServiceProtocol
        
        //MARK: init et injection de dépendance
        init(candidate: Candidate,
             isAdmin: Bool,
             candidateService: CandidateServiceProtocol = CandidateService()
        ) {
                self.candidate = candidate
                self.isAdmin = isAdmin
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
        
        //Annule l'édition et revient au mode lecture.
        func cancelEditing() {
                self.isEditing = false
        }
        
        // Sauvegarde les modifications via l'API.
        func saveChanges() async {
                /// appel aux validateurs
                validateEmail()
                validatePhone()
                /// verification des erreurs en même temps
                guard emailErrorMessage == nil && phoneErrorMessage == nil else {
                        self.errorMessage = "Veuillez corriger les erreurs avant de sauvegarder."
                        return
                }
                isLoading = true
                errorMessage = nil
                defer { isLoading = false }
                
                // Crée le "payload" (DTO) à partir des données éditées
                let payload = CandidatePayloadDTO(
                        firstName: editableFirstName,
                        lastName: editableLastName,
                        email: editableEmail,
                        phone: editablePhone.isEmpty ? nil : editablePhone,
                        note: editableNote.isEmpty ? nil : editableNote,
                        linkedinURL: editableLinkedinURL.isEmpty ? nil : editableLinkedinURL
                )
                
                do {
                        // Appelle le service de mise à jour
                        let updatedCandidateDTO = try await candidateService.updateCandidate(id: candidate.id, with: payload)
                        
                        // Met à jour le modèle principal avec la réponse du serveur
                        self.candidate = Candidate(from: updatedCandidateDTO)
                        
                        // Quitte le mode édition
                        self.isEditing = false
                        
                } catch let error as APIServiceError {
                        self.errorMessage = error.localizedDescription
                } catch {
                        self.errorMessage = "Une erreur de sauvegarde inattendue est survenue."
                }
        }
        func toggleFavoriteStatus() async {
                errorMessage = nil /// On efface les anciens messages
                isTogglingFavorite = true
                defer { isTogglingFavorite = false }
                
                do {
                        let updatedCandidateDTO = try await candidateService.toggleFavoriteStatus(id: candidate.id)
                        self.candidate = Candidate(from: updatedCandidateDTO)
                        print("Statut favori mis à jour pour : \(self.candidate.firstName)")
                } catch let error as APIServiceError {
                        // On affiche les erreurs de notre service
                        errorMessage = error.localizedDescription
                } catch {
                        // On affiche les erreurs inattendues
                        errorMessage = "Une erreur inattendue est survenue."
                        print("Erreur toggleFavoriteStatus: \(error.localizedDescription)")
                }
        }
        
        //MARK: valider l'email
        func validateEmail() {
                if !editableEmail.isValidEmail {
                        emailErrorMessage = "Le format de l'email est invalide."
                } else {
                        emailErrorMessage = nil
                }
        }
        
        //MARK: valider le téléphone
        func validatePhone() {
                // Le téléphone est optionnel, donc on ne valide que s'il n'est pas vide
                if !editablePhone.isEmpty && !editablePhone.isValidPhoneNumber {
                        phoneErrorMessage = "Le format du téléphone est invalide (chiffres uniquement)."
                } else {
                        phoneErrorMessage = nil
                }
        }
}
