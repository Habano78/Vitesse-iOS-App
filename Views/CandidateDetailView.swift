//
//  CandidateDetailView.swift
//  Vitesse
//
//  Created by Perez William on 02/07/2025.
//
import SwiftUI

struct CandidateDetailView: View {
        
        // MARK: Properties
        @StateObject private var viewModel: CandidateDetailViewModel
        // Gère le focus du clavier pour les champs de texte en mode édition.
        @FocusState private var isEditingFocus: Bool
        
        let isAdmin: Bool /// Statut de l'utilisateur reçu de la vue précédente.
        
        // MARK: Initialization
        init(candidate: Candidate, isAdmin: Bool) {
                self.isAdmin = isAdmin
                // On initialise le StateObject ici, en lui passant les données nécessaires.
                _viewModel = StateObject(wrappedValue: CandidateDetailViewModel(
                        candidate: candidate,
                        isAdmin: isAdmin
                ))
        }
        
        // MARK: Body
        var body: some View {
                // Group pour appliquer des modificateurs communs aux deux états de la vue.
                Group {
                        if viewModel.isEditing {
                                editableCandidateView
                        } else {
                                readOnlyCandidateView
                        }
                }
                // Le titre de la barre de navigation change en fonction du mode.
                .navigationTitle(viewModel.isEditing ? "Édition du Profil" : "")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(viewModel.isEditing)
                .toolbar {
                        // La barre d'outils est dynamique et affiche les bons boutons selon le mode.
                        if viewModel.isEditing {
                                editingToolbar
                        } else {
                                readingToolbar
                        }
                }
                // alerte modale pour toute erreur venant du ViewModel.
                .alert("Erreur", isPresented: Binding(
                        get: { viewModel.errorMessage != nil },
                        set: { if !$0 { viewModel.errorMessage = nil } }
                )) {
                        Button("OK") {}
                } message: {
                        Text(viewModel.errorMessage ?? "Une erreur inconnue est survenue.")
                }
        }
        
        // MARK: Subviews
        /// Vue affichée en mode lecture, fidèle au wireframe.
        private var readOnlyCandidateView: some View {
                ScrollView {
                        VStack(alignment: .leading, spacing: 30) {
                                // En-tête avec le nom et le bouton pour les favoris.
                                HStack(alignment: .top) {
                                        Text("\(viewModel.candidate.firstName) \(viewModel.candidate.lastName)")
                                                .font(.largeTitle)
                                                .fontWeight(.bold)
                                        Spacer()
                                        Button {
                                                Task { await viewModel.toggleFavoriteStatus() }
                                        } label: {
                                                Image(systemName: viewModel.candidate.isFavorite ? "star.fill" : "star")
                                                        .font(.title2)
                                        }
                                        .tint(.yellow)
                                        .disabled(!viewModel.isAdmin)
                                }
                                
                                // Utilisation d'une Grid pour un alignement parfait en colonnes.
                                Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 18) {
                                        GridRow {
                                                Text("Phone").font(.headline)
                                                Text(viewModel.candidate.phone ?? "Non renseigné").foregroundColor(.secondary)
                                        }
                                        GridRow {
                                                Text("Email").font(.headline)
                                                Text(viewModel.candidate.email).foregroundColor(.secondary)
                                        }
                                        GridRow(alignment: .top) {
                                                Text("LinkedIn").font(.headline)
                                                if let urlString = viewModel.candidate.linkedinURL, !urlString.isEmpty, let url = URL(string: urlString) {
                                                        Link("Go on LinkedIn", destination: url)
                                                } else {
                                                        Text("Non renseigné").foregroundColor(.secondary)
                                                }
                                        }
                                }
                                
                                // Section pour les notes.
                                VStack(alignment: .leading, spacing: 8) {
                                        Text("Note").font(.headline)
                                        Text(viewModel.candidate.note ?? "Aucune note")
                                                .padding()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color(.secondarySystemBackground))
                                                .cornerRadius(8)
                                }
                        }
                        .padding()
                }
        }
        
        /// Vue affichée en mode édition, utilisant un Form pour une saisie facile.
        private var editableCandidateView: some View {
                Form {
                        Section("Informations Personnelles") {
                                TextField("Prénom", text: $viewModel.editableFirstName)
                                TextField("Nom", text: $viewModel.editableLastName)
                        }
                        Section("Contact") {
                                TextField("Email", text: $viewModel.editableEmail)
                                        .keyboardType(.emailAddress).autocapitalization(.none)
                                        .onChange(of: viewModel.editableEmail) { viewModel.validateEmail() }
                                
                                if let emailError = viewModel.emailErrorMessage {
                                        Text(emailError).font(.caption).foregroundColor(.red)
                                }
                        }
                        Section("Téléphone") {
                                TextField("Téléphone", text: $viewModel.editablePhone)
                                        .keyboardType(.phonePad)
                                        .onChange(of: viewModel.editablePhone) { viewModel.validatePhone() }
                                
                                if let phoneError = viewModel.phoneErrorMessage {
                                        Text(phoneError).font(.caption).foregroundColor(.red)
                                }
                        }
                        Section("Profil LinkedIn") {
                                TextField("URL LinkedIn", text: $viewModel.editableLinkedinURL).keyboardType(.URL)
                        }
                        Section("Notes") {
                                TextEditor(text: $viewModel.editableNote).frame(minHeight: 150)
                        }
                }
                .listStyle(.insetGrouped)
        }
        
        // MARK: - Toolbar Content
        
        /// Barre d'outils pour le mode lecture.
        @ToolbarContentBuilder
        private var readingToolbar: some ToolbarContent {
                ToolbarItem(placement: .topBarTrailing) {
                        Button("Edit") {
                                viewModel.startEditing()
                        }
                }
        }
        
        /// Barre d'outils pour le mode édition.
        @ToolbarContentBuilder
        private var editingToolbar: some ToolbarContent {
                ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                                viewModel.cancelEditing()
                        }
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

// MARK: - Preview

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
                                        note: "Physicienne et chimiste, pionnière dans le domaine de la radioactivité.",
                                        linkedinURL: "https://linkedin.com/in/mariecurie",
                                        isFavorite: true
                                )
                        ),
                        isAdmin: true
                )
        }
}
