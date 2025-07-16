//
//  AuthViewModel.swift
//  Vitesse
//
//  Created by Perez William on 01/07/2025.
//

import Foundation

@MainActor
class AuthViewModel: ObservableObject {
        
        // MARK: Propriétés liées au champ d'authentiification
        @Published var email: String = ""
        @Published var password: String = ""
        
        // MARK: Propriétés d'état de l'UI
        @Published var isLoading: Bool = false
        @Published var errorMessage: String?
        
        // MARK: Dépendances & Callbacks
        private let authService: AuthenticationServiceProtocol
        
        let onLoginSucceed: ((AuthResponseDTO) -> Void)
        
        //MARK: Init
        init(authService: AuthenticationServiceProtocol, onLoginSucceed: @escaping (AuthResponseDTO) -> Void) {
                self.authService = authService
                self.onLoginSucceed = onLoginSucceed
        }
        
        //MARK: Actions
        func login() async {
                isLoading = true
                errorMessage = nil
                defer { isLoading = false }
                
                ///Prépare le DTO pour la requête en nettoyant l'email.
                let trimmedEmail = self.email.trimmingCharacters(in: .whitespacesAndNewlines)
                let loginCredentials = AuthRequestDTO(email: trimmedEmail, password: self.password)
                
                /// Appelle le service et gère la réponse.
                do {
                        let userSession = try await authService.login(credentials: loginCredentials)
                        print("AuthenticationViewModel: Connexion réussie. Token: \(userSession.token.prefix(8))...")
                        
                        onLoginSucceed(userSession) /// ici on notifie la vue parente du succès de connex
                        
                } catch let error as APIServiceError {
                        errorMessage = error.errorDescription
                } catch {
                        errorMessage = "Erreur inattendue.Veuillez réessayer."
                }
        }
}
