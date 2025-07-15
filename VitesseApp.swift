//
//  VitesseApp.swift
//  Vitesse
//
//  Created by Perez William on 30/06/2025.
//

import SwiftUI

@main
struct VitesseApp: App {
        
        // MARK: - Propriétés d'État
        
        
        @State private var isAuthenticated: Bool
        @State private var isAdmin: Bool
        
        private let tokenManager = AuthTokenPersistence()
        
        // MARK: - Init
        init() {
                var hasToken = false
                do {
                        if try tokenManager.retrieveToken() != nil {
                                hasToken = true
                        }
                } catch {
                        print("Erreur de lecture du Keychain au démarrage: \(error)")
                        hasToken = false
                }
                
                // Init des propriétés @State
                _isAuthenticated = State(initialValue: hasToken)
                _isAdmin = State(initialValue: false)
        }
        
        // MARK: corps
        var body: some Scene {
                WindowGroup {
                        if isAuthenticated {
                                CandidateListView(isAdmin: isAdmin, onLogout: logout)
                        } else {
                                AuthView(
                                        authService: AuthService(),
                                        onLoginSucceed: { authResponse in
                                                handleLoginSuccess(with: authResponse)
                                        }
                                )
                        }
                }
        }
        
        // MARK: - Méthodes privées
        private func handleLoginSuccess(with response: AuthResponseDTO) {
                do {
                        try tokenManager.saveToken(response.token)
                        self.isAdmin = response.isAdmin
                        self.isAuthenticated = true
                } catch {
                        print("ERREUR: Impossible de sauvegarder le token. Erreur: \(error.localizedDescription)")
                }
        }
        
        /// Gère la déconnexion de l'utilisateur en effaçant le token et en réinitialisant l'état de l'UI.
        private func logout() {
                do {
                        try tokenManager.deleteToken()
                } catch {
                        print("Erreur lors de la suppression du token: \(error.localizedDescription)")
                }
                self.isAuthenticated = false
                self.isAdmin = false
        }
}
