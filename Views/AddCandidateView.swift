//
//  AddCandidateView.swift
//  VitesseTests
//
//  Created by Perez William on 06/07/2025.
//

import SwiftUI

struct AddCandidateView: View {
        
        // On crée une instance du ViewModel pour cette vue
        @StateObject private var viewModel: AddCandidateViewModel
        
        // Le @Environment nous permettra de fermer la vue (la feuille modale)
        @Environment(\.dismiss) private var dismiss
        
        // La vue reçoit le callback à exécuter en cas de succès
        init(onCandidateAdded: @escaping (Candidate) -> Void) {
                _viewModel = StateObject(wrappedValue: AddCandidateViewModel(
                        onCandidateAdded: onCandidateAdded
                ))
        }
        
        var body: some View {
                NavigationStack {
                        Form {
                                Section("Informations Personnelles") {
                                        TextField("Prénom (requis)", text: $viewModel.firstName)
                                        TextField("Nom (requis)", text: $viewModel.lastName)
                                }
                                
                                Section("Contact") {
                                        TextField("Email (requis)", text: $viewModel.email)
                                                .keyboardType(.emailAddress)
                                                .autocapitalization(.none)
                                        TextField("Téléphone", text: $viewModel.phone)
                                                .keyboardType(.phonePad)
                                        TextField("Profil LinkedIn", text: $viewModel.linkedinURL)
                                                .keyboardType(.URL)
                                }
                                
                                Section("Notes") {
                                        TextEditor(text: $viewModel.note)
                                                .frame(minHeight: 150)
                                }
                                
                                if let errorMessage = viewModel.errorMessage {
                                        Section {
                                                Text(errorMessage)
                                                        .foregroundColor(.red)
                                        }
                                }
                        }
                        .navigationTitle("Nouveau Candidat")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                        Button("Annuler") {
                                                dismiss() // Ferme la feuille
                                        }
                                }
                                
                                ToolbarItem(placement: .confirmationAction) {
                                        if viewModel.isLoading {
                                                ProgressView()
                                        } else {
                                                Button("Ajouter") {
                                                        Task {
                                                                await viewModel.addCandidate()
                                                        }
                                                }
                                        }
                                }
                        }
                }
        }
}
