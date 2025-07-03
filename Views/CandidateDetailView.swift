//
//  CandidateDetailView.swift
//  Vitesse
//
//  Created by Perez William on 02/07/2025.
//
import SwiftUI

struct CandidateDetailView: View {
        
        // MARK: - Properties
        
        @StateObject private var viewModel: CandidateDetailViewModel
        
        // MARK: - Initialization
        
        init(candidate: Candidate) {
                _viewModel = StateObject(wrappedValue: CandidateDetailViewModel(candidate: candidate))
        }
        
        // MARK: - Body
        
        var body: some View {
                Form {
                        Section(header: Text("Informations Personnelles")) {
                                // On affiche soit un Text, soit un TextField en fonction du mode édition
                                if viewModel.isEditing {
                                        TextField("Prénom", text: $viewModel.editableFirstName)
                                        TextField("Nom", text: $viewModel.editableLastName)
                                } else {
                                        Text(viewModel.candidate.lastName)
                                        Text(viewModel.candidate.firstName)
                                }
                        }
                        
                        Section(header: Text("Contact")) {
                                if viewModel.isEditing {
                                        TextField("Email", text: $viewModel.editableEmail)
                                                .keyboardType(.emailAddress)
                                        TextField("Téléphone", text: $viewModel.editablePhone)
                                                .keyboardType(.phonePad)
                                        TextField("Profil LinkedIn", text: $viewModel.editableLinkedinURL)
                                                .keyboardType(.URL)
                                } else {
                                        Text(viewModel.candidate.email)
                                        if let phone = viewModel.candidate.phone, !phone.isEmpty {
                                                Text(phone)
                                        }
                                        if let linkedin = viewModel.candidate.linkedinURL, !linkedin.isEmpty {
                                                Text(linkedin)
                                        }
                                }
                        }
                        
                        Section(header: Text("Notes")) {
                                if viewModel.isEditing {
                                        // TextEditor est plus adapté pour du texte multi-lignes
                                        TextEditor(text: $viewModel.editableNote)
                                                .frame(minHeight: 150)
                                } else {
                                        if let note = viewModel.candidate.note, !note.isEmpty {
                                                Text(note)
                                        } else {
                                                Text("Aucune note").italic().foregroundColor(.secondary)
                                        }
                                }
                        }
                        
                        // On affiche le message d'erreur s'il y en a un
                        if let errorMessage = viewModel.errorMessage {
                                Section {
                                        Text(errorMessage)
                                                .foregroundColor(.red)
                                }
                        }
                }
                .navigationTitle(viewModel.isEditing ? "Édition" : "\(viewModel.candidate.firstName) \(viewModel.candidate.lastName)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                        // Le contenu de la toolbar change aussi en fonction du mode
                        if viewModel.isEditing {
                                // Boutons en mode édition
                                ToolbarItem(placement: .cancellationAction) {
                                        Button("Annuler") {
                                                viewModel.cancelEditing()
                                        }
                                }
                                ToolbarItem(placement: .confirmationAction) {
                                        // On affiche un spinner si la sauvegarde est en cours
                                        if viewModel.isLoading {
                                                ProgressView()
                                        } else {
                                                Button("Sauvegarder") {
                                                        Task {
                                                                await viewModel.saveChanges()
                                                        }
                                                }
                                        }
                                }
                        } else {
                                // Boutons en mode lecture
                                ToolbarItem(placement: .navigationBarTrailing) {
                                        // Bouton Favori
                                        Button {
                                                Task {
                                                        await viewModel.toggleFavoriteStatus()
                                                }
                                        } label: {
                                                Image(systemName: viewModel.candidate.isFavorite ? "star.fill" : "star")
                                                        .foregroundColor(.yellow)
                                        }
                                        
                                        // Bouton Modifier
                                        Button("Modifier") {
                                                viewModel.startEditing()
                                        }
                                }
                        }
                }
        }
}
