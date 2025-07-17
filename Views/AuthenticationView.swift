//
//  AuthView.swift
//  Vitesse
//
//  Created by Perez William on 01/07/2025.
//

import SwiftUI
import Foundation

struct AuthView: View {
        
        // MARK: Properties
        @StateObject private var viewModel: AuthViewModel
        @FocusState private var focusedField: AuthField? 
        @State private var isShowingRegisterView = false
        
        // Enum pour gérer le focus entre les champs
        enum AuthField {
                case email
                case password
        }
        
        // MARK: Initialization
        init(authService: AuthenticationServiceProtocol, onLoginSucceed: @escaping (AuthResponseDTO) -> Void) {
                _viewModel = StateObject(wrappedValue: AuthViewModel(
                        authService: authService,
                        onLoginSucceed: onLoginSucceed
                ))
        }
        
        // MARK: - Body
        var body: some View {
                NavigationStack {
                        ScrollView {
                                VStack(spacing: 20) {
                                        Text("Login")
                                                .font(.largeTitle).fontWeight(.bold)
                                                .padding(.top, 50)
                                                .padding(.bottom, 30)
                                        
                                        // --- Champs de saisie ---
                                        VStack(alignment: .leading, spacing: 15) {
                                                // Champ Email
                                                VStack(alignment: .leading) {
                                                        Text("Email/Username").font(.footnote).foregroundColor(.gray)
                                                        TextField("Enter your email", text: $viewModel.email)
                                                                .keyboardType(.emailAddress)
                                                                .autocapitalization(.none)
                                                                .textContentType(.emailAddress)
                                                                .standardTextFieldStyle()
                                                                .focused($focusedField, equals: .email)
                                                                .onSubmit { focusedField = .password } // Passe au suivant
                                                }
                                                
                                                // Champ Mot de passe
                                                VStack(alignment: .leading) {
                                                        Text("Password").font(.footnote).foregroundColor(.gray)
                                                        SecureField("Enter your password", text: $viewModel.password)
                                                                .textContentType(.password)
                                                                .standardTextFieldStyle()
                                                                .focused($focusedField, equals: .password)
                                                                .onSubmit { Task { await viewModel.login() } } // Lance la connexion
                                                }
                                                
                                                // Lien Mot de passe oublié
                                                HStack {
                                                        Spacer()
                                                        Button("Forgot password?") {
                                                                print("Forgot password tapped.")
                                                        }
                                                        .font(.footnote)
                                                        .tint(.gray)
                                                }
                                        }
                                        
                                        // --- Message d'erreur ---
                                        if let errorMessage = viewModel.errorMessage {
                                                Text(errorMessage)
                                                        .foregroundColor(.red).font(.footnote)
                                                        .multilineTextAlignment(.center).padding(.top)
                                        }
                                        
                                        // --- Boutons d'action ---
                                        VStack(spacing: 15) {
                                                if viewModel.isLoading {
                                                        ProgressView()
                                                } else {
                                                        // Bouton Sign In
                                                        Button("Sign in") { Task { await viewModel.login() } }
                                                                .frame(maxWidth: .infinity)
                                                                .padding().background(Color.black)
                                                                .foregroundColor(.white).cornerRadius(10)
                                                        
                                                        // Bouton Register
                                                        Button("Register") { isShowingRegisterView = true }
                                                                .frame(maxWidth: .infinity)
                                                                .padding()
                                                                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1.5))
                                                                .foregroundColor(.black)
                                                }
                                        }
                                        .padding(.top, 30)
                                }
                                .padding(.horizontal, 40)
                        }
                        .navigationBarHidden(true)
                        .onTapGesture { focusedField = nil } // Ferme le clavier
                        .sheet(isPresented: $isShowingRegisterView) {
                                RegisterView(onRegisterSucceed: {
                                        isShowingRegisterView = false
                                })
                        }
                }
        }
}
