//
//  VitesseApp.swift
//  Vitesse
//
//  Created by Perez William on 30/06/2025.
//
///On est ici sur le point d'entrée principal de l'application Vitesse/// Ici on gère l'état d'authentification global (`isAuthenticated`, `isAdmin`)
/// et on orchestre la vue à afficher au démarrage : l'écran de connexion ou la liste principale.


import SwiftUI

@main
struct VitesseApp: App {
        
        // MARK: - Propriétés d'État
        
        
        @State private var isAuthenticated: Bool /// est-ce que  l'utilisateur est actuellement connecté ?
        @State private var isAdmin: Bool /// est-ce ue l'utilisateur a les droits d'administrateur ?
        
        private let tokenManager = AuthTokenPersistence() /// gestionnaire pour la persistance du token
        
        // MARK: - Init
        init() {
                var hasToken = false
                do {
                        if try tokenManager.retrieveToken() != nil {  /// vérification de token existant
                                hasToken = true
                        }
                } catch {
                        print("Erreur de lecture du Keychain au démarrage: \(error)")
                        hasToken = false
                }
                
                // Init des propriétés @State
                _isAuthenticated = State(initialValue: hasToken)
                _isAdmin = State(initialValue: false) /// Le statut admin sera défini après une nouvelle connexion.
        }
        
        // MARK: corps
        var body: some Scene {
                WindowGroup {
                        if isAuthenticated {  /// Affiche la vue appropriée en fonction de l'état d'authentification.
                                CandidateListView(isAdmin: isAdmin, onLogout: logout) /// Si l'utilisateur est connecté, on affiche la liste des candidats
                                
                        } else {  /// Sinon, on affiche l'écran de connexion
                                AuthView(
                                        authService: AuthService(),
                                        onLoginSucceed: { authResponse in
                                                handleLoginSuccess(with: authResponse)  ///callback exécuté par AuthViewModel en cas de succès
                                        }
                                )
                        }
                }
        }
        
        // MARK: - Méthodes privées
        private func handleLoginSuccess(with response: AuthResponseDTO) { /// actions à effectuer après une connexion réussie.
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
                self.isAuthenticated = false /// Quoi qu'il arrive, on déconnecte l'utilisateur de l'interface./
                self.isAdmin = false
        }
}
