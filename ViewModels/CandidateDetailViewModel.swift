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
        
        //MARK: init et injection
        init(candidate: Candidate,
             isAdmin: Bool,
             candidateService: CandidateServiceProtocol = CandidateService()
        ) {
                self.candidate = candidate
                self.isAdmin = isAdmin
                self.candidateService = candidateService
        }
        
        // MARK: Actions -- startEditing, cancelEditing, saveChanges, toggleFavoriteStatus, validateEmail, validatePhone --
        
        func startEditing() {
                // On passe en mode édition
                isEditing = true
                
                // On copie les valeurs du candidat dans les variables éditables
                editableFirstName = candidate.firstName
                editableLastName = candidate.lastName
                editableEmail = candidate.email
                editablePhone = candidate.phone ?? ""
                editableNote = candidate.note ?? ""
                editableLinkedinURL = candidate.linkedinURL ?? ""
                
                // On s'assure que les messages d'erreur sont vides au début
                emailErrorMessage = nil
                phoneErrorMessage = nil
                errorMessage = nil
        }
        
        //Annule l'édition et revient au mode lecture.
        func cancelEditing() {
                isEditing = false
        }
        
        // Sauvegarde les modifications via l'API.
        func saveChanges() async {
                /// appel aux valideurs
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
                        candidate = Candidate(from: updatedCandidateDTO)
                        
                        // Quitte le mode édition
                        isEditing = false
                        
                } catch let error as APIServiceError {
                        errorMessage = error.localizedDescription
                } catch {
                        errorMessage = "Une erreur de sauvegarde inattendue est survenue."
                }
        }
        //changement de statut favori
        func toggleFavoriteStatus() async {
                errorMessage = nil /// pour effacer les anciens messages
                isTogglingFavorite = true
                defer { isTogglingFavorite = false }
                
                do {
                        let updatedCandidateDTO = try await candidateService.toggleFavoriteStatus(id: candidate.id)
                        candidate = Candidate(from: updatedCandidateDTO)
                } catch let error as APIServiceError {
                        // On affiche les erreurs du service
                        errorMessage = error.localizedDescription
                } catch {
                        // On affiche les erreurs inattendues
                        errorMessage = "Une erreur inattendue est survenue."
                }
        }
        
        // valider l'email
        func validateEmail() {
                if !editableEmail.isValidEmail {
                        emailErrorMessage = "Le format de l'email est invalide."
                } else {
                        emailErrorMessage = nil
                }
        }
        
        // valider le téléphone
        func validatePhone() {
                // Le téléphone est optionnel, donc on ne valide que s'il n'est pas vide
                if !editablePhone.isEmpty && !editablePhone.isValidPhoneNumber {
                        phoneErrorMessage = "Le format du téléphone est invalide (chiffres uniquement)."
                } else {
                        phoneErrorMessage = nil
                }
        }
}
