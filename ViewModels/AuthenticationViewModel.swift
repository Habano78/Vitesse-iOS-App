//
//  AuthViewModel.swift
//  Vitesse
//
//  Created by Perez William on 01/07/2025.
//

import Foundation

/// Gère la logique et l'état de la vue d'authentification (`AuthView`).
@MainActor
class AuthViewModel: ObservableObject {
        
        // MARK: - Propriétés liées au formulaire
        @Published var email: String = ""
        @Published var password: String = ""
        
        // MARK: - Propriétés d'état de l'UI
        @Published var isLoading: Bool = false
        @Published var errorMessage: String?
        
        // MARK: - Dépendances & Callbacks
        private let authService: AuthenticationServiceProtocol
        
        let onLoginSucceed: ((AuthResponseDTO) -> Void) /// callback pour notifier VitesseApp du succès de connexion
        
        //MARK: Init
        init(authService: AuthenticationServiceProtocol, onLoginSucceed: @escaping (AuthResponseDTO) -> Void) {
                self.authService = authService
                self.onLoginSucceed = onLoginSucceed
        }
        
        //MARK: Actions
        func login() async {  /// Fonction qui  gère l'état de chargement, prépare les données, appelle le service et traite les cas de succès ou d'erreur.
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
                        
                        self.onLoginSucceed(userSession) /// ici on notifie la vue parente du succès de connex
                        
                } catch let error as APIServiceError {
                        errorMessage = error.errorDescription /// message d'erreur si l'erreur vient de notre couche API.
                } catch {
                        errorMessage = "Erreur inattendue.Veuillez réessayer." /// message générique pour toute autre erreur inattendue.
                }
        }
}
