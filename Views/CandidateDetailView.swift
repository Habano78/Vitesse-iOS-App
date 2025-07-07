//
//  CandidateDetailView.swift
//  Vitesse
//
//  Created by Perez William on 02/07/2025.
//
import SwiftUI

struct CandidateDetailView: View {
        
        @StateObject private var viewModel: CandidateDetailViewModel
        
        let isAdmin: Bool
        
        init(candidate: Candidate, isAdmin: Bool) {
                self.isAdmin = isAdmin
                _viewModel = StateObject(wrappedValue: CandidateDetailViewModel(
                        candidate: candidate,
                        isAdmin: isAdmin
                ))
        }
        
        var body: some View {
                // En mode édition, on utilise la vue avec les champs de texte
                if viewModel.isEditing {
                        editableCandidateView
                } else {
                        // En mode lecture, on utilise la vue personnalisée
                        readOnlyCandidateView
                }
        }
        
        // MARK: - Vue en Mode Lecture (Conforme au Wireframe)
        private var readOnlyCandidateView: some View {
                ScrollView {
                        VStack(alignment: .leading, spacing: 25) {
                                // Grand titre avec le nom et le bouton favori
                                HStack {
                                        Text("\(viewModel.candidate.firstName) \(viewModel.candidate.lastName)")
                                                .font(.largeTitle)
                                                .fontWeight(.bold)
                                        Spacer()
                                        
                                        // Bouton favori, conditionné par le statut admin
                                        Button {
                                                Task { await viewModel.toggleFavoriteStatus() }
                                        } label: {
                                                Image(systemName: viewModel.candidate.isFavorite ? "star.fill" : "star")
                                                        .foregroundColor(.yellow)
                                                        .font(.title2)
                                        }
                                        .disabled(!viewModel.isAdmin)
                                }
                                
                                // Section Contact
                                VStack(alignment: .leading, spacing: 15) {
                                        if let phone = viewModel.candidate.phone, !phone.isEmpty {
                                                detailRow(label: "Phone", value: phone)
                                        }
                                        detailRow(label: "Email", value: viewModel.candidate.email)
                                        
                                        if let urlString = viewModel.candidate.linkedinURL, let url = URL(string: urlString) {
                                                // Le bouton pour ouvrir LinkedIn
                                                Link(destination: url) {
                                                        Text("Go on LinkedIn")
                                                                .font(.headline)
                                                                .frame(maxWidth: 150)
                                                                .padding(8)
                                                                .background(Color.blue.opacity(0.1))
                                                                .foregroundColor(.blue)
                                                                .cornerRadius(8)
                                                }
                                        }
                                }
                                
                                // Section Notes
                                VStack(alignment: .leading) {
                                        Text("Note")
                                                .font(.headline)
                                                .padding(.bottom, 5)
                                        
                                        Text(viewModel.candidate.note ?? "Aucune note")
                                                .padding()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color(.secondarySystemBackground))
                                                .cornerRadius(8)
                                }
                        }
                        .padding()
                }
                .navigationTitle("") // Assure que la barre de nav est vide
                .alert("Erreur", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                        Button("OK") {
                                // En cliquant sur OK, on efface le message pour faire disparaître l'alerte
                                viewModel.errorMessage = nil
                        }
                }, message: {
                        Text(viewModel.errorMessage ?? "Une erreur inconnue est survenue.")
                })
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                                Button("Edit") {
                                        viewModel.startEditing()
                                }
                        }
                }
        }
        
        // MARK: Vue en Mode Édition (Utilise un Form)
        private var editableCandidateView: some View {
                Form {
                        Section("Informations Personnelles") {
                                TextField("Prénom", text: $viewModel.editableFirstName)
                                TextField("Nom", text: $viewModel.editableLastName)
                        }
                        
                        Section("Contact") {
                                TextField("Email", text: $viewModel.editableEmail).keyboardType(.emailAddress)
                                TextField("Téléphone", text: $viewModel.editablePhone).keyboardType(.phonePad)
                                TextField("Profil LinkedIn", text: $viewModel.editableLinkedinURL).keyboardType(.URL)
                        }
                        
                        Section("Notes") {
                                TextEditor(text: $viewModel.editableNote)
                                        .frame(minHeight: 150)
                        }
                        
                        if let errorMessage = viewModel.errorMessage {
                                Section { Text(errorMessage).foregroundColor(.red) }
                        }
                }
                .navigationTitle("\(viewModel.candidate.firstName) \(viewModel.candidate.lastName)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { viewModel.cancelEditing() }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                                if viewModel.isLoading {
                                        ProgressView()
                                } else {
                                        Button("Done") { Task { await viewModel.saveChanges() } }
                                }
                        }
                }
        }
        
        //  fonction d'aide pour éviter la répétition
        @ViewBuilder
        private func detailRow(label: String, value: String) -> some View {
                VStack(alignment: .leading) {
                        Text(label)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        Text(value)
                }
        }
}
