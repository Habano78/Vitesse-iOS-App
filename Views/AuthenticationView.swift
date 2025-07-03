//
//  AuthView.swift
//  Vitesse
//
//  Created by Perez William on 01/07/2025.
//

import SwiftUI

struct AuthView: View {
        
        // MARK: - Properties
        // Crée et conserve une instance du ViewModel
        @StateObject private var viewModel: AuthViewModel
        
        init(viewModel: AuthViewModel) {
            _viewModel = StateObject(wrappedValue: viewModel)
        }

        
        // Gère l'état du focus des champs de texte pour pouvoir fermer le clavier.
        @FocusState private var isInputActive: Bool
        
        // MARK: - Initialization
        init(authService: AuthenticationServiceProtocol, onLoginSucceed: @escaping (AuthResponseDTO) -> Void) {
                // Pour initialiser un @StateObject dans un init, on doit utiliser la syntaxe
                // avec un underscore (_) pour accéder au "property wrapper" lui-même.
                _viewModel = StateObject(wrappedValue: AuthViewModel(
                        authService: authService,
                        onLoginSucceed: onLoginSucceed
                ))
        }
        
        // MARK: - Body
        var body: some View {
                VStack(spacing: 20) {
                        
                        Text("Welcome !")
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                        
                        TextField("Adresse email", text: $viewModel.email)
                                .focused($isInputActive)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(8)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .disableAutocorrection(true)
                        
                        SecureField("Mot de passe", text: $viewModel.password)
                                .focused($isInputActive)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(8)
                        
                        // Bouton de connexion et indicateur de chargement
                        if viewModel.isLoading {
                                ProgressView()
                        } else {
                                Button(action: {
                                        // On appelle la fonction async du ViewModel à l'intérieur d'un Task
                                        Task {
                                                await viewModel.login()
                                        }
                                }) {
                                        Text("Se connecter")
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.black)
                                                .cornerRadius(8)
                                }
                                .disabled(viewModel.isLoading)
                        }
                        
                        // Affichage du message d'erreur
                        if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true)
                        }
                }
                .padding(.horizontal, 40)
                .onTapGesture {
                        // Ferme le clavier quand on touche en dehors des champs
                        isInputActive = false
                }
        }
}


