//
//  CandidateListView.swift
//  Vitesse
//
//  Created by Perez William on 01/07/2025.
//
import SwiftUI

struct CandidateListView: View {
        
        // MARK: Properties
        @StateObject private var viewModel = CandidateListViewModel()
        
        // États locaux pour gérer l'interface
        @State private var isEditing = false
        @State private var selection = Set<UUID>()
        // état pour déclencher la navigation manuellement
        @State private var candidateToNavigate: Candidate?
        
        // Propriétés reçues de la vue parente
        let isAdmin: Bool
        let onLogout: () -> Void
        
        
        // MARK: Init
        init(isAdmin: Bool, onLogout: @escaping () -> Void) {
                self.isAdmin = isAdmin
                self.onLogout = onLogout
        }
        
        // MARK: Body
        var body: some View {
                NavigationStack {
                        VStack(spacing: 0) {
                                List {
                                        ForEach(viewModel.candidates) { candidate in
                                                NavigationLink(value: candidate) {
                                                        HStack {
                                                                if isEditing {
                                                                        Image(systemName: selection.contains(candidate.id) ? "checkmark.circle.fill" : "circle")
                                                                                .font(.title2)
                                                                                .foregroundColor(.accentColor)
                                                                }
                                                                Text("\(candidate.firstName) \(candidate.lastName)")
                                                                Spacer()
                                                                if candidate.isFavorite {
                                                                        Image(systemName: "star.fill")
                                                                                .foregroundColor(.yellow)
                                                                }
                                                        }
                                                }
                                                .padding(.vertical, 8)
                                                .onTapGesture {
                                                        if isEditing {
                                                                toggleSelection(for: candidate)
                                                        } else {
                                                                // En mode normal, on définit quel candidat on veut voir
                                                                candidateToNavigate = candidate
                                                        }
                                                }
                                        }
                                }
                                .listStyle(.insetGrouped)
                                .navigationDestination(for: Candidate.self) { candidate in
                                        if !isEditing {
                                                CandidateDetailView(candidate: candidate, isAdmin: isAdmin)
                                        }
                                }
                                
                                // Bouton de déconnexion en bas de l'écran
                                Button("Logout", role: .destructive) {
                                        onLogout()
                                }
                                .padding()
                        }
                        .navigationTitle("")
                        .navigationDestination(item: $candidateToNavigate) { candidate in
                                CandidateDetailView(candidate: candidate, isAdmin: isAdmin)
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .searchable(text: $viewModel.searchText, prompt: "Search")
                        .toolbar {
                                // Affiche la barre d'outils correspondante au mode actuel
                                if isEditing {
                                        editingToolbar
                                } else {
                                        defaultToolbar
                                }
                        }
                        .environment(\.editMode, .constant(isEditing ? .active : .inactive))
                        .onAppear {
                                Task {
                                        await viewModel.fetchCandidates()
                                }
                        }
                        .overlay {
                                // Affiche les états de chargement, d'erreur ou de liste vide
                                if viewModel.isLoading { ProgressView() }
                                else if let errorMessage = viewModel.errorMessage {
                                        ContentUnavailableView("Erreur", systemImage: "wifi.slash", description: Text(errorMessage))
                                }
                                else if viewModel.candidates.isEmpty && !viewModel.searchText.isEmpty {
                                        ContentUnavailableView.search
                                }
                                else if viewModel.candidates.isEmpty {
                                        ContentUnavailableView("Aucun Candidat", systemImage: "person.3.fill")
                                }
                        }
                }
        }
        
        // MARK: - Toolbar Views
        
        /// Barre d'outils pour le mode de lecture normal.
        @ToolbarContentBuilder
        private var defaultToolbar: some ToolbarContent {
                // Le bouton "Edit" à gauche
                ToolbarItem(placement: .topBarLeading) {
                        Button("Edit") {
                                withAnimation { isEditing = true }
                        }
                }
                
                // Le titre "Candidats" au centre
                ToolbarItem(placement: .principal) {
                        Text("Candidats")
                                .fontWeight(.semibold)
                }
                
                // bouton "Favoris" à droite
                ToolbarItem(placement: .topBarTrailing) {
                        Button {
                                viewModel.isFavoritesFilterActive.toggle()
                        } label: {
                                Image(systemName: viewModel.isFavoritesFilterActive ? "star.fill" : "star")
                        }
                        .tint(.yellow)
                }
        }
        
        // Barre d'outils pour le mode d'édition.
        @ToolbarContentBuilder
        private var editingToolbar: some ToolbarContent {
                ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                                withAnimation {
                                        isEditing = false
                                        selection.removeAll()
                                }
                        }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                        Button("Delete", role: .destructive) {
                                Task {
                                        await viewModel.deleteSelectedCandidates(ids: selection)
                                        withAnimation {
                                                isEditing = false
                                                selection.removeAll()
                                        }
                                }
                        }
                        .disabled(selection.isEmpty)
                }
        }
        
        // MARK: - Helper Functions
        
        /// Ajoute ou retire un candidat du set de sélection.
        private func toggleSelection(for candidate: Candidate) {
                let candidateID = candidate.id
                if selection.contains(candidateID) {
                        selection.remove(candidateID)
                } else {
                        selection.insert(candidateID)
                }
        }
}
