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
                NavigationStack {
                        VStack(spacing: 0) { // Espacement général à 0, on gère avec des paddings
                                
                                Spacer() // Pousse le contenu au centre
                                
                                Text("Login")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .padding(.bottom, 40)
                                
                                // Conteneur pour les champs de saisie
                                VStack(spacing: 15) {
                                        VStack(alignment: .leading) {
                                                Text("E-mail/Username")
                                                        .font(.footnote)
                                                        .foregroundColor(.gray)
                                                TextField("enter your e-mail", text: $viewModel.email)
                                                        .textFieldStyle(.roundedBorder)
                                                        .keyboardType(.emailAddress)
                                                        .autocapitalization(.none)
                                                        .disableAutocorrection(true)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                                Text("Password")
                                                        .font(.footnote)
                                                        .foregroundColor(.gray)
                                                SecureField("enter your password", text: $viewModel.password)
                                                        .textFieldStyle(.roundedBorder)
                                        }
                                }
                                .padding(.horizontal, 40) // 1. Padding de référence pour les champs
                                
                                ///Conteneur pour les boutons
                                VStack(spacing: 15) {
                                        if viewModel.isLoading {
                                                ProgressView()
                                                        .padding(.top, 20)
                                        } else {
                                
                                                Button("Sign in") {
                                                        Task { await viewModel.login() }
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.black)
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                                
                                                Button("Register") {
                                                        isShowingRegisterView = true
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(
                                                        RoundedRectangle(cornerRadius: 10)
                                                                .stroke(Color.black, lineWidth: 1.5)
                                                )
                                                .foregroundColor(.black)
                                        }
                                }
                                .padding(.horizontal, 55)
                                .padding(.top, 30)
                                
                                Spacer() // pour pousser le contenu au centre
                                
                                // Affichage des erreurs en bas
                                if let errorMessage = viewModel.errorMessage {
                                        Text(errorMessage)
                                                .foregroundColor(.red)
                                                .font(.caption)
                                                .multilineTextAlignment(.center)
                                                .padding()
                                }
                        }
                        .background(Color(.systemGroupedBackground))
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture { isInputActive = false }
                        .sheet(isPresented: $isShowingRegisterView) {
                                NavigationStack {
                                        RegisterView(onRegisterSucceed: {
                                                isShowingRegisterView = false
                                        })
                                }
                        }
                }
        }
}
