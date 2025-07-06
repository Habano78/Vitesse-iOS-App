//
//  VitesseApp.swift
//  Vitesse
//
//  Created by Perez William on 30/06/2025.
//

import SwiftUI

@main
struct VitesseApp: App {
        @State private var isAuthenticated: Bool
        @State private var isAdmin: Bool
        
        private let tokenManager = AuthTokenPersistence()
        
        init() {
                // ... votre code init existant ...
                var hasToken = false
                do {
                        if try tokenManager.retrieveToken() != nil {
                                hasToken = true
                        }
                } catch {
                        print("Erreur de lecture du Keychain au démarrage: \(error)")
                        hasToken = false
                }
                _isAuthenticated = State(initialValue: hasToken)
                _isAdmin = State(initialValue: false)
        }
        
        var body: some Scene {
                WindowGroup {
                        if isAuthenticated {
                                // 2. On passe la fonction logout à la vue
                                CandidateListView(isAdmin: isAdmin, onLogout: logout)
                        } else {
                                AuthView(
                                        authService: AuthService(),
                                        onLoginSucceed: { authResponse in
                                                do {
                                                        try tokenManager.saveToken(authResponse.token)
                                                        self.isAdmin = authResponse.isAdmin
                                                        self.isAuthenticated = true
                                                } catch {
                                                        print("ERREUR: Impossible de sauvegarder le token. Erreur: \(error.localizedDescription)")
                                                }
                                        }
                                )
                        }
                }
        }
        
        //MARK: fonction pour la déconnexion
        private func logout() {
                do {
                        try tokenManager.deleteToken()
                        self.isAuthenticated = false
                        self.isAdmin = false // On réinitialise aussi le statut admin
                } catch {
                        print("Erreur lors de la suppression du token: \(error.localizedDescription)")
                        // même si la suppression échoue, on déconnecte l'utilisateur de l'UI
                        self.isAuthenticated = false
                        self.isAdmin = false
                }
        }
}
