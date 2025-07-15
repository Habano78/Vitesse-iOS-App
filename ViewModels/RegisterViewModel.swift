//
//  RegisterViewModel.swift
//  Vitesse
//
//  Created by Perez William on 03/07/2025.
//

import Foundation

@MainActor
class RegisterViewModel: ObservableObject {
        
        // MARK: - Propriétés liées au formulaire
        @Published var firstName = ""
        @Published var lastName = ""
        @Published var email = ""
        @Published var password = ""
        @Published var confirmPassword = ""
        
        // MARK: - Propriétés d'état pour l'UI
        @Published var isLoading = false
        @Published var errorMessage: String?
        @Published var emailErrorMessage: String?
        
        // MARK: - Dépendances & Callbacks
        private let authService: AuthenticationServiceProtocol
        
        // Un callback pour signaler le succès à la vue parente
        // afin qu'elle puisse fermer l'écran d'inscription.
        let onRegisterSucceed: () -> Void
        
        init(
                authService: AuthenticationServiceProtocol = AuthService(),
                onRegisterSucceed: @escaping () -> Void
        ) {
                self.authService = authService
                self.onRegisterSucceed = onRegisterSucceed
        }
        
        //MARK: fonction de validation
        func validateEmail() {
                if !email.isValidEmail {
                        emailErrorMessage = "Le format de l'email est invalide."
                } else {
                        emailErrorMessage = nil
                }
        }
        
        // MARK: - Actions
        
        func register() async {
                // vérification de la validité de l'émail
                validateEmail()
                guard emailErrorMessage == nil else { return }
                // vérification des champs
                guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty else {
                        errorMessage = "Tous les champs sont obligatoires."
                        return
                }
                // verification des mots de passe
                guard password == confirmPassword else {
                        errorMessage = "Les mots de passe ne correspondent pas."
                        return
                }
                
                // Appel au service
                isLoading = true
                errorMessage = nil
                defer { isLoading = false }
                
                // On crée le DTO avec les données du formulaire
                let registrationDetails = UserRegisterRequestDTO(
                        email: email,
                        password: password,
                        firstName: firstName,
                        lastName: lastName
                )
                
                do {
                        try await authService.register(with: registrationDetails)
                        
                        onRegisterSucceed()
                        
                } catch let error as APIServiceError {
                        errorMessage = error.localizedDescription
                } catch {
                        errorMessage = "Une erreur d'inscription inattendue est survenue."
                }
        }
}
