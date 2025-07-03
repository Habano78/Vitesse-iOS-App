//
//  VitesseApp.swift
//  Vitesse
//
//  Created by Perez William on 30/06/2025.
//

import SwiftUI

@main
struct VitesseApp: App {
        
        // MARK: - Propriété pour contrôler l'état de connexion
        @State private var isAuthenticated: Bool = false
        
        var body: some Scene {
                WindowGroup {
                        // On utilise la condition pour choisir quelle vue construire et afficher.
                        if isAuthenticated {
                                // Si l'utilisateur est connecté, on affiche la liste des candidats.
                                CandidateListView()
                        } else {
                                // Sinon, on affiche l'écran de connexion.
                                // On déplace l'initialisation correcte ici.
                                AuthView(
                                        authService: AuthService(),
                                        onLoginSucceed: { authResponse in
                                                
                                                // On sauvegarde le token dans le Keychain.
                                                let tokenManager = AuthTokenPersistence()
                                                do {
                                                        try tokenManager.saveToken(authResponse.token)
                                                } catch {
                                                        print("ERREUR: Impossible de sauvegarder le token. Erreur: \(error.localizedDescription)")
                                                }
                                                
                                                // On met à jour notre état, ce qui va automatiquement
                                                // faire basculer l'affichage vers CandidateListView.
                                                self.isAuthenticated = true
                                        }
                                )
                        }
                }
        }
}
