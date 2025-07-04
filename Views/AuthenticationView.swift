//
//  AuthView.swift
//  Vitesse
//
//  Created by Perez William on 01/07/2025.
//

import SwiftUI

struct AuthView: View {
        
        // MARK: - Properties
        
        @StateObject private var viewModel: AuthViewModel
        @FocusState private var isInputActive: Bool
        
        // État pour gérer l'affichage de la feuille d'inscription
        @State private var isShowingRegisterView = false
        
        // MARK: - Initialization
        
        init(authService: AuthenticationServiceProtocol, onLoginSucceed: @escaping (AuthResponseDTO) -> Void) {
                _viewModel = StateObject(wrappedValue: AuthViewModel(
                        authService: authService,
                        onLoginSucceed: onLoginSucceed
                ))
        }
        
        // MARK: - Body
        var body: some View {
                // Le NavigationStack est utile pour afficher un titre de page.
                NavigationStack {
                        VStack(spacing: 20) {
                                
                                Text("Welcome !")
                                        .font(.largeTitle)
                                        .fontWeight(.semibold)
                                        .padding(.bottom, 20)
                                
                                TextField("Adresse email", text: $viewModel.email)
                                        .focused($isInputActive)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                
                                SecureField("Mot de passe", text: $viewModel.password)
                                        .focused($isInputActive)
                                
                                if viewModel.isLoading {
                                        ProgressView()
                                } else {
                                        Button("Se connecter") {
                                                Task { await viewModel.login() }
                                        }
                                        .disabled(viewModel.isLoading)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.black)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                
                                Button("Créer un compte") {
                                        isShowingRegisterView = true
                                }
                                .padding(.top)
                                
                                if let errorMessage = viewModel.errorMessage {
                                        Text(errorMessage)
                                                .foregroundColor(.red)
                                                .font(.caption)
                                                .multilineTextAlignment(.center)
                                }
                        }
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 40)
                        .navigationTitle("Connexion")
                        .navigationBarTitleDisplayMode(.inline)
                        .onTapGesture {
                                isInputActive = false
                        }
                }
                .sheet(isPresented: $isShowingRegisterView) {
                        // Présente la RegisterView dans une feuille modale.
                        // On l'enveloppe dans une NavigationStack pour qu'elle ait sa propre barre de titre.
                        NavigationStack {
                                RegisterView(onRegisterSucceed: {
                                        // Quand l'inscription réussit, on ferme la feuille.
                                        isShowingRegisterView = false
                                })
                        }
                }
        }
}
