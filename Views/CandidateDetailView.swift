//
//  CandidateDetailView.swift
//  Vitesse
//
//  Created by Perez William on 02/07/2025.
//
import SwiftUI

struct CandidateDetailView: View {
        
        @StateObject private var viewModel: CandidateDetailViewModel
        @FocusState private var isEditingFocus: Bool // Pour gérer le clavier en mode édition
        
        let isAdmin: Bool
        
        init(candidate: Candidate, isAdmin: Bool) {
                self.isAdmin = isAdmin
                _viewModel = StateObject(wrappedValue: CandidateDetailViewModel(candidate: candidate, isAdmin: isAdmin))
        }
        
        var body: some View {
                Group {
                        if viewModel.isEditing {
                                editableCandidateView
                        } else {
                                readOnlyCandidateView
                        }
                }
                .navigationTitle(viewModel.isEditing ? "Édition" : "")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(viewModel.isEditing)
                .toolbar {
                        if viewModel.isEditing {
                                editingToolbar
                        } else {
                                readingToolbar
                        }
                }
                .alert("Erreur", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                        Button("OK") { viewModel.errorMessage = nil }
                }, message: {
                        Text(viewModel.errorMessage ?? "Une erreur est survenue.")
                })
        }
        
        // MARK: - Vue en Mode Lecture (Version finale corrigée)
        private var readOnlyCandidateView: some View {
                ScrollView {
                        // Conteneur principal centré et limité en largeur
                        VStack(alignment: .leading, spacing: 50) {
                                
                                // En-tête
                                HStack(alignment: .top) {
                                        Text("\(viewModel.candidate.firstName) \(viewModel.candidate.lastName)")
                                                .font(.largeTitle)
                                                .fontWeight(.bold)
                                        
                                        Spacer()
                                        //
                                        Button {
                                                Task { await viewModel.toggleFavoriteStatus() }
                                        } label: {
                                                Image(systemName: viewModel.candidate.isFavorite ? "star.fill" : "star")
                                                        .font(.title2)
                                        }
                                        .tint(.yellow)
                                        .disabled(!isAdmin)
                                }
                                
                                // --- Infos personnelles ---
                                Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 18) {
                                        GridRow {
                                                Text("Phone")
                                                        .font(.headline)
                                                Text(viewModel.candidate.phone ?? "Non renseigné")
                                                        .foregroundColor(.secondary)
                                        }
                                        
                                        GridRow {
                                                Text("Email")
                                                        .font(.headline)
                                                Text(viewModel.candidate.email)
                                                        .foregroundColor(.secondary)
                                        }
                                        
                                        GridRow(alignment: .center) {
                                                Text("LinkedIn")
                                                        .font(.headline)
                                                
                                                if let urlString = viewModel.candidate.linkedinURL,
                                                   !urlString.isEmpty,
                                                   let url = URL(string: urlString) {
                                                        Link(destination: url) {
                                                                Text("Go on LinkedIn")
                                                                        .font(.subheadline)
                                                                        .padding(.horizontal, 12)
                                                                        .padding(.vertical, 6)
                                                                        .background(
                                                                                RoundedRectangle(cornerRadius: 8)
                                                                                        .stroke(Color.blue, lineWidth: 1)
                                                                        )
                                                        }
                                                } else {
                                                        Text("Non renseigné")
                                                                .foregroundColor(.secondary)
                                                }
                                        }
                                        
                                }
                                
                                // --- Notes ---
                                VStack(alignment: .leading, spacing: 8) {
                                        Text("Note")
                                                .font(.headline)
                                        
                                        Text(viewModel.candidate.note ?? "Aucune note")
                                                .padding()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color(.secondarySystemBackground))
                                                .cornerRadius(8)
                                }
                        }
                        .frame(maxWidth: 330) // 👈 même largeur que "Note"
                        .padding()
                        .background(Color.clear) // utile si tu veux tester en debug
                }
                
                // On s'assure que la barre de navigation est vide pour laisser place au titre dans la vue
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
        }
        
        private var editableCandidateView: some View {
                ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                                
                                // Nom complet affiché comme titre (lecture seule)
                                Text("\(viewModel.candidate.firstName) \(viewModel.candidate.lastName)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .padding(.horizontal)
                                        .padding(.top)
                                
                                // Champ téléphone
                                VStack(alignment: .leading, spacing: 6) {
                                        Text("Phone")
                                                .font(.headline)
                                        TextField("Phone", text: $viewModel.editablePhone)
                                                .textFieldStyle(.roundedBorder)
                                }
                                .padding(.horizontal)
                                
                                // Champ e-mail
                                VStack(alignment: .leading, spacing: 6) {
                                        Text("Email")
                                                .font(.headline)
                                        TextField("Email", text: $viewModel.editableEmail)
                                                .keyboardType(.emailAddress)
                                                .autocapitalization(.none)
                                                .textFieldStyle(.roundedBorder)
                                                .onChange(of: viewModel.editableEmail) {
                                                        viewModel.validateEmail()
                                                }
                                        
                                        if let emailError = viewModel.emailErrorMessage {
                                                Text(emailError)
                                                        .font(.caption)
                                                        .foregroundColor(.red)
                                        }
                                }
                                .padding(.horizontal)
                                
                                // Champ LinkedIn
                                VStack(alignment: .leading, spacing: 6) {
                                        Text("LinkedIn")
                                                .font(.headline)
                                        TextField("LinkedIn URL", text: $viewModel.editableLinkedinURL)
                                                .textFieldStyle(.roundedBorder)
                                }
                                .padding(.horizontal)
                                
                                // Champ Note
                                VStack(alignment: .leading, spacing: 6) {
                                        Text("Note")
                                                .font(.headline)
                                        TextEditor(text: $viewModel.editableNote)
                                                .padding(8)
                                                .frame(minHeight: 120)
                                                .background(Color(.secondarySystemBackground))
                                                .cornerRadius(10)
                                }
                                .padding(.horizontal)
                        }
                        .padding(.top)
                }
        }
        
        // MARK: - Toolbars
        @ToolbarContentBuilder
        private var readingToolbar: some ToolbarContent {
                ToolbarItem(placement: .topBarTrailing) {
                        Button("Edit") { viewModel.startEditing() }
                }
        }
        
        @ToolbarContentBuilder
        private var editingToolbar: some ToolbarContent {
                ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { viewModel.cancelEditing() }
                }
                ToolbarItem(placement: .confirmationAction) {
                        if viewModel.isLoading {
                                ProgressView()
                        } else {
                                Button("Done") { Task { await viewModel.saveChanges() } }
                                        .disabled(viewModel.emailErrorMessage != nil || viewModel.phoneErrorMessage != nil)
                        }
                }
        }
}

//MARK: Preview
#Preview {
        NavigationStack {
                CandidateDetailView(
                        candidate: Candidate(
                                from: .init(
                                        id: UUID(),
                                        firstName: "Marie",
                                        lastName: "Curie",
                                        email: "marie@curie.fr",
                                        phone: "0123456789",
                                        note: "Physicienne et chimiste, pionnière dans le domaine de la radioactivité.Physicienne et chimiste, pionnière dans le domaine de la radioactivité. Physicienne et chimiste, pionnière dans le domaine de la radioactivité",
                                        linkedinURL: "https://linkedin.com/in/mariecurie",
                                        isFavorite: true
                                )
                        ),
                        isAdmin: true // On peut tester les deux cas
                )
        }
}
