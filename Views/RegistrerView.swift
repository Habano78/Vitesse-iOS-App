//
//  RegistrerView.swift
//  Vitesse
//
//  Created by Perez William on 03/07/2025.
//

import SwiftUI

struct RegisterView: View {
        
        // MARK: - Properties
        @StateObject private var viewModel: RegisterViewModel
        @FocusState private var isInputActive: Bool
        
        // MARK: - Initialization
        // La vue reçoit une "action de succès" pour savoir quoi faire
        // une fois l'inscription terminée (par exemple, fermer cet écran).
        init(onRegisterSucceed: @escaping () -> Void) {
                _viewModel = StateObject(wrappedValue: RegisterViewModel(
                        onRegisterSucceed: onRegisterSucceed
                ))
        }
        
        // MARK: - Body
        var body: some View {
                VStack(spacing: 20) {
                        
                        // --- Champs de saisie ---
                        TextField("Prénom", text: $viewModel.firstName)
                                .focused($isInputActive)
                        
                        TextField("Nom", text: $viewModel.lastName)
                                .focused($isInputActive)
                        
                        TextField("Adresse email", text: $viewModel.email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .focused($isInputActive)
                        
                        SecureField("Mot de passe", text: $viewModel.password)
                                .focused($isInputActive)
                        
                        SecureField("Confirmer le mot de passe", text: $viewModel.confirmPassword)
                                .focused($isInputActive)
                        
                        // --- Bouton d'action et indicateur de chargement ---
                        if viewModel.isLoading {
                                ProgressView()
                        } else {
                                Button("S'inscrire") {
                                        Task {
                                                await viewModel.register()
                                        }
                                }
                                .disabled(viewModel.isLoading)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        // --- Affichage du message d'erreur ---
                        if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                        }
                }
                .textFieldStyle(.roundedBorder) // Style commun pour tous les champs
                .padding()
                .navigationTitle("Créer un compte")
                .onTapGesture {
                        isInputActive = false // Ferme le clavier au toucher
                }
        }
}
