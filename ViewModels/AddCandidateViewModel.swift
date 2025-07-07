//
//  AddCandidateViewModel.swift
//  VitesseTests
//
//  Created by Perez William on 06/07/2025.
//

import Foundation

@MainActor
class AddCandidateViewModel: ObservableObject {
        
        // MARK: - Propriétés liées au formulaire
        @Published var firstName = ""
        @Published var lastName = ""
        @Published var email = ""
        @Published var phone = ""
        @Published var note = ""
        @Published var linkedinURL = ""
        
        // MARK: - Propriétés d'état pour l'UI
        @Published var isLoading = false
        @Published var errorMessage: String?
        @Published var emailErrorMessage: String?
        @Published var phoneErrorMessage: String?
        
        // MARK: - Dépendances & Callbacks
        private let candidateService: CandidateServiceProtocol
        
        // Callback pour signaler que le candidat a été ajouté
        let onCandidateAdded: (Candidate) -> Void
        
        init(
                candidateService: CandidateServiceProtocol = CandidateService(),
                onCandidateAdded: @escaping (Candidate) -> Void
        ) {
                self.candidateService = candidateService
                self.onCandidateAdded = onCandidateAdded
        }
        
        //MARK: FONCTIONS DE VALIDATION
        func validateEmail() {
                if !email.isValidEmail {
                        emailErrorMessage = "Le format de l'email est invalide."
                } else {
                        emailErrorMessage = nil
                }
        }
        
        func validatePhone() {
                if !phone.isEmpty && !phone.isValidPhoneNumber {
                        phoneErrorMessage = "Le format du téléphone est invalide."
                } else {
                        phoneErrorMessage = nil
                }
        }
        
        // MARK: Actions
        func addCandidate() async {
                // Appel aux validateurs de format mail et phone
                validateEmail()
                validatePhone()
                guard emailErrorMessage == nil && phoneErrorMessage == nil else {
                        errorMessage = "Veuillez corriger le format des champs obligatoires."
                        return
                }
                // Validation des champs obligatoires
                guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty else {
                        errorMessage = "Le prénom, le nom et l'email sont obligatoires."
                        return
                }
                
                isLoading = true
                errorMessage = nil
                defer { isLoading = false }
                
                // On crée le payload avec les données du formulaire
                let payload = CandidatePayloadDTO(
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        phone: phone.isEmpty ? nil : phone,
                        note: note.isEmpty ? nil : note,
                        linkedinURL: linkedinURL.isEmpty ? nil : linkedinURL
                )
                
                do {
                        // On appelle la nouvelle fonction du service
                        let newCandidateDTO = try await candidateService.createCandidate(with: payload)
                        
                        // On convertit le DTO en modèle métier
                        let newCandidate = Candidate(from: newCandidateDTO)
                        
                        // On exécute le callback de succès pour fermer la vue et rafraîchir la liste
                        onCandidateAdded(newCandidate)
                        
                } catch let error as APIServiceError {
                        self.errorMessage = error.localizedDescription
                } catch {
                        self.errorMessage = "Une erreur inattendue est survenue."
                }
        }
}
