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
                                                Text("Email/Username")
                                                        .font(.footnote)
                                                        .foregroundColor(.gray)
                                                TextField("Enter your email", text: $viewModel.email)
                                                        .padding(.horizontal)
                                                        .frame(height: 40)
                                                        .background(Color.white)
                                                        .cornerRadius(8)
                                                        .overlay(
                                                                RoundedRectangle(cornerRadius: 8)
                                                                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                                        )
                                                        .keyboardType(.emailAddress)
                                                        .autocapitalization(.none)
                                                        .disableAutocorrection(true)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                                Text("Password")
                                                        .font(.footnote)
                                                        .foregroundColor(.gray)
                                                SecureField("Enter your password", text: $viewModel.password)
                                                        .padding(.horizontal)
                                                        .frame(height: 40)
                                                        .background(Color.white)
                                                        .cornerRadius(8)
                                                        .overlay(
                                                                RoundedRectangle(cornerRadius: 8)
                                                                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                                        )
                                                //MARK: FORGOT PASSWORD
                                                HStack {
                                                        Button("Forgot password?") {
                                                                // Pour l'instant, l'action ne fait rien
                                                                print("Bouton 'Mot de passe oublié' cliqué.")
                                                                print("l'API ne fournit pas les endpoints nécessaires pour ce processus")
                                                        }
                                                        .font(.footnote)
                                                        .tint(.gray) //couleur discrète
                                                }
                                        }
                                }
                                .padding(.top, 30)
                                .padding(.horizontal, 40) ///Padding pour les champs
                                
                                // Affichage erreurs d'identifiants
                                if let errorMessage = viewModel.errorMessage {
                                        Text(errorMessage)
                                                .foregroundColor(.red)
                                                .font(.caption)
                                                .multilineTextAlignment(.center)
                                                .padding()
                                }
                                Spacer()
                                //MARK: Conteneur pour les boutons
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
                                                .frame(height: 40)
                                                .frame(width: 160)
                                                .background(Color.black)
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                                
                                                Button("Register") {
                                                        isShowingRegisterView = true
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding(.horizontal)
                                                .frame(height: 35)
                                                .frame(width: 160)
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
                                Spacer() // pour pousser le contenu au centre
                                
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
