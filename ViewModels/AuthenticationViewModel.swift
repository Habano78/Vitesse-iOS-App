//
//  AuthViewModel.swift
//  Vitesse
//
//  Created by Perez William on 01/07/2025.
//

import Foundation

@MainActor
class AuthViewModel: ObservableObject {
        
        @Published var email: String = ""
        @Published var password: String = ""
        
        //MARK: État initial pour la Vue
        @Published var isLoading: Bool = false
        @Published var errorMessage: String?
        
        //MARK: service d'authentification.
        private let authService: AuthenticationServiceProtocol
        
        //MARK: Callback
        let onLoginSucceed: ((AuthResponseDTO) -> Void)
        
        init(authService: AuthenticationServiceProtocol, onLoginSucceed: @escaping (AuthResponseDTO) -> Void) {
                self.authService = authService 
                self.onLoginSucceed = onLoginSucceed
        }
        
        func login() async {
                isLoading = true
                defer { isLoading = false }
                errorMessage = nil
                
                //MARK: Préparation des données pour la requête
                let  loginCredentials  = AuthRequestDTO(email: self.email, password: self.password)
                
                //MARK: Appel au Service et gérer la réponse
                do {
                        let userSession = try await authService.login(credentials: loginCredentials)
                        print("AuthenticationViewModel: Connexion réussie via le service. Token: \(userSession.token.prefix(8))")
                        self.onLoginSucceed(userSession)
                } catch let error as APIServiceError {
                        self.errorMessage = error.errorDescription
                }catch {
                        self.errorMessage = "Erreur inattendue.Veuillez réessayer."
                }
        }
}
