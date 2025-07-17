//
//  RegisterView.swift
//  Vitesse
//
//  Created by Perez William on 03/07/2025.
//
import SwiftUI

struct RegisterView: View {
        
        // MARK: - Properties
        @StateObject private var viewModel: RegisterViewModel
        
        // Enumération des champs focusables
        private enum FocusField: Hashable {
                case firstName, lastName, email, password, confirmPassword
        }
        
        @FocusState private var focusedField: FocusField?
        
        // MARK: - Init
        init(onRegisterSucceed: @escaping () -> Void) {
                _viewModel = StateObject(wrappedValue: RegisterViewModel(
                        onRegisterSucceed: onRegisterSucceed
                ))
        }
        
        // MARK: - Body
        var body: some View {
                NavigationStack {
                        ScrollView {
                                VStack(spacing: 15) {
                                        Text("Register")
                                                .font(.largeTitle)
                                                .fontWeight(.bold)
                                                .padding(.vertical, 20)
                                        
                                        VStack(alignment: .leading, spacing: 15) {
                                                // Champ First Name
                                                createLabeledTextField(
                                                        label: "First Name",
                                                        placeholder: "Enter first name",
                                                        text: $viewModel.firstName,
                                                        focus: .firstName
                                                )
                                                
                                                // Champ Last Name
                                                createLabeledTextField(
                                                        label: "Last Name",
                                                        placeholder: "Enter last name",
                                                        text: $viewModel.lastName,
                                                        focus: .lastName
                                                )
                                                
                                                // Champ Email
                                                VStack(alignment: .leading) {
                                                        Text("Email")
                                                                .font(.footnote)
                                                                .foregroundColor(.gray)
                                                        TextField("Enter email", text: $viewModel.email)
                                                                .keyboardType(.emailAddress)
                                                                .autocapitalization(.none)
                                                                .disableAutocorrection(true)
                                                                .modifier(StandardTextFieldModifier())
                                                                .focused($focusedField, equals: .email)
                                                                .onChange(of: viewModel.email) {
                                                                        viewModel.validateEmail()
                                                                }
                                                                .submitLabel(.next)
                                                                .onSubmit {
                                                                        focusedField = .password
                                                                }
                                                        
                                                        if let emailError = viewModel.emailErrorMessage {
                                                                Text(emailError)
                                                                        .font(.caption)
                                                                        .foregroundColor(.red)
                                                                        .padding(.leading, 5)
                                                        }
                                                }
                                                
                                                // Champ Password
                                                createLabeledSecureField(
                                                        label: "Password",
                                                        placeholder: "Enter password",
                                                        text: $viewModel.password,
                                                        focus: .password
                                                )
                                                
                                                // Champ Confirm Password
                                                createLabeledSecureField(
                                                        label: "Confirm Password",
                                                        placeholder: "Confirm password",
                                                        text: $viewModel.confirmPassword,
                                                        focus: .confirmPassword
                                                )
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
                                                        focusedField = nil // ferme le clavier
                                                        Task { await viewModel.register() }
                                                }
                                                .padding(.vertical, 12)
                                                .padding(.horizontal, 50)
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
                        .onAppear {
                            focusedField = .firstName /// focalise automatiquement le premier champ du formulaire
                        }
                        .onTapGesture {
                                focusedField = nil /// Ferme le clavier si on tape à côté
                        }
                }
        }
        
        // MARK: Helper TextField
        private func createLabeledTextField(label: String, placeholder: String, text: Binding<String>, focus: FocusField) -> some View {
                VStack(alignment: .leading) {
                        Text(label)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        TextField(placeholder, text: text)
                                .modifier(StandardTextFieldModifier())
                                .focused($focusedField, equals: focus)
                                .submitLabel(.next)
                                .onSubmit {
                                        focusNext(after: focus)
                                }
                }
        }
        
        private func createLabeledSecureField(label: String, placeholder: String, text: Binding<String>, focus: FocusField) -> some View {
                VStack(alignment: .leading) {
                        Text(label)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        SecureField(placeholder, text: text)
                                .modifier(StandardTextFieldModifier())
                                .focused($focusedField, equals: focus)
                                .submitLabel(focus == .confirmPassword ? .done : .next)
                                .onSubmit {
                                        focusNext(after: focus)
                                }
                }
        }
        
        // MARK: Navigation logique entre les champs
        private func focusNext(after current: FocusField) {
                switch current {
                case .firstName:
                        focusedField = .lastName
                case .lastName:
                        focusedField = .email
                case .email:
                        focusedField = .password
                case .password:
                        focusedField = .confirmPassword
                case .confirmPassword:
                        focusedField = nil // Ferme le clavier
                }
        }
}
