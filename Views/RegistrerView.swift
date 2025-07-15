//
//  RegisterView.swift
//  Vitesse
//
//  Created by Perez William on 03/07/2025.
//
import SwiftUI

struct RegisterView: View {
        
        // MARK: Properties
        @StateObject private var viewModel: RegisterViewModel 
        @FocusState private var isInputActive: Bool ///contrôler quel champ de texte est actif
        
        // MARK: Init
        init(onRegisterSucceed: @escaping () -> Void) {
                _viewModel = StateObject(wrappedValue: RegisterViewModel(
                        onRegisterSucceed: onRegisterSucceed
                ))
        }
        
        // MARK: Body
        var body: some View {
                NavigationStack {
                        ScrollView {
                                VStack(spacing: 15) {
                                        Text("Register")
                                                .font(.largeTitle)
                                                .fontWeight(.bold)
                                                .padding(.vertical, 20)
                                        
                                        // Champs de saisie
                                        VStack(alignment: .leading, spacing: 15) {
                                                createLabeledTextField(label: "First Name", placeholder: "Enter first name", text: $viewModel.firstName)
                                                
                                                createLabeledTextField(label: "Last Name", placeholder: "Enter last name", text: $viewModel.lastName)
                                                
                                                // Champ Email avec sa validation
                                                VStack(alignment: .leading) {
                                                        Text("Email").font(.footnote).foregroundColor(.gray)
                                                        TextField("Enter email", text: $viewModel.email)
                                                                .keyboardType(.emailAddress)
                                                                .autocapitalization(.none)
                                                                .disableAutocorrection(true)
                                                                .modifier(StandardTextFieldModifier())
                                                                .focused($isInputActive)
                                                                .onChange(of: viewModel.email) { viewModel.validateEmail() }
                                                        
                                                        if let emailError = viewModel.emailErrorMessage {
                                                                Text(emailError)
                                                                        .font(.caption)
                                                                        .foregroundColor(.red)
                                                                        .padding(.leading, 5)
                                                        }
                                                }
                                                
                                                createLabeledSecureField(label: "Password", placeholder: "Enter password", text: $viewModel.password)
                                                
                                                createLabeledSecureField(label: "Confirm Password", placeholder: "Confirm password", text: $viewModel.confirmPassword)
                                        }
                                        .padding(.top, 40)
                                        .padding(.horizontal, 40)
                                        
                                        // Message d'erreur général
                                        if let errorMessage = viewModel.errorMessage {
                                                Text(errorMessage)
                                                        .foregroundColor(.red)
                                                        .font(.footnote)
                                                        .multilineTextAlignment(.center)
                                                        .padding(.top)
                                        }
                                        
                                        // Bouton d'action
                                        if viewModel.isLoading {
                                                ProgressView()
                                                        .padding(.top, 20)
                                        } else {
                                                Button("Create") {
                                                        Task { await viewModel.register() }
                                                }
                                                .padding(.vertical, 12) // Padding vertical pour la hauteur
                                                .padding(.horizontal, 50) // Padding horizontal pour la largeur
                                                .background(
                                                        RoundedRectangle(cornerRadius: 10)
                                                                .stroke(Color.black, lineWidth: 1.5)
                                                )
                                                .foregroundColor(.black)
                                                .padding(.top, 20)
                                                .padding(.horizontal)
                                        }
                                }
                        }
                        .navigationBarHidden(true)
                        .onTapGesture { isInputActive = false }
                }
        }
        
        // MARK: Fonctions assistantes
        /// Crée un champ de texte standard avec un label.
        private func createLabeledTextField(label: String, placeholder: String, text: Binding<String>) -> some View {
                VStack(alignment: .leading) {
                        Text(label)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        TextField(placeholder, text: text)
                                .modifier(StandardTextFieldModifier())
                                .focused($isInputActive)
                }
        }
        
        /// Crée un champ de texte sécurisé standard avec un label.
        private func createLabeledSecureField(label: String, placeholder: String, text: Binding<String>) -> some View {
                VStack(alignment: .leading) {
                        Text(label)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        SecureField(placeholder, text: text)
                                .modifier(StandardTextFieldModifier())
                                .focused($isInputActive)
                }
        }
}

// MARK: - Preview

#Preview {
        RegisterView(onRegisterSucceed: {
                print("Registration would succeed.")
        })
        .background(Color(.systemGroupedBackground))
}
