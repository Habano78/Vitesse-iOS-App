//
//  CandidateListView.swift
//  Vitesse
//
//  Created by Perez William on 01/07/2025.
//
import SwiftUI

struct CandidateListView: View {
        
        @StateObject private var viewModel = CandidateListViewModel()
        @State private var isEditing = false
        
        //Nouvel état pour contrôler l'affichage de la feuille d'ajout
        @State private var isShowingAddCandidateSheet = false
        
        let isAdmin: Bool
        let onLogout: () -> Void
        
        init(isAdmin: Bool, onLogout: @escaping () -> Void) {
                self.isAdmin = isAdmin
                self.onLogout = onLogout
        }
        
        var body: some View {
                NavigationStack {
                        List {
                                ForEach(viewModel.candidates) { candidate in
                                        HStack {
                                                NavigationLink(destination: CandidateDetailView(candidate: candidate, isAdmin: self.isAdmin)) {
                                                        HStack {
                                                                Text("\(candidate.firstName) \(candidate.lastName)")
                                                                Spacer()
                                                                if candidate.isFavorite {
                                                                        Image(systemName: "star.fill")
                                                                                .foregroundColor(.yellow)
                                                                }
                                                        }
                                                }
                                        }
                                }
                                .onDelete(perform: delete)
                        }
                        .navigationTitle("Candidats")
                        .navigationBarTitleDisplayMode(.inline)
                        .searchable(text: $viewModel.searchText, prompt: "Search")
                        .toolbar {
                                ToolbarItemGroup(placement: .topBarLeading) {
                                        Button("Logout", role: .destructive) {
                                                onLogout()
                                        }
                                        Button(isEditing ? "Done" : "Edit") {
                                                withAnimation {
                                                        isEditing.toggle()
                                                }
                                        }
                                }
                                
                                // On regroupe les boutons de droite
                                ToolbarItemGroup(placement: .topBarTrailing) {
                                        // Le bouton "+" ne s'affiche que pour les admins
                                        if isAdmin {
                                                Button {
                                                        isShowingAddCandidateSheet = true
                                                } label: {
                                                        Image(systemName: "plus")
                                                }
                                        }
                                        
                                        // Le bouton pour filtrer les favoris
                                        Button {
                                                viewModel.isFavoritesFilterActive.toggle()
                                        } label: {
                                                Image(systemName: viewModel.isFavoritesFilterActive ? "star.fill" : "star")
                                        }
                                        .tint(.yellow)
                                }
                        }
                        .environment(\.editMode, .constant(isEditing ? .active : .inactive))
                        .onAppear {
                                Task {
                                        await viewModel.fetchCandidates()
                                }
                        }
                        .overlay {
                                // ... votre code .overlay reste identique ...
                                if viewModel.isLoading {
                                        ProgressView()
                                } else if let errorMessage = viewModel.errorMessage {
                                        ContentUnavailableView("Erreur", systemImage: "wifi.slash", description: Text(errorMessage))
                                } else if viewModel.candidates.isEmpty && !viewModel.searchText.isEmpty {
                                        ContentUnavailableView.search
                                } else if viewModel.candidates.isEmpty {
                                        ContentUnavailableView("Aucun Candidat", systemImage: "person.3.fill")
                                }
                        }
                        // 3. On attache la feuille modale ici
                        .sheet(isPresented: $isShowingAddCandidateSheet) {
                                AddCandidateView { newCandidate in
                                        // Ce code est exécuté quand un candidat est ajouté avec succès
                                        viewModel.addCandidateToList(newCandidate)
                                        isShowingAddCandidateSheet = false // On ferme la feuille
                                }
                        }
                }
        }
        
        private func delete(at offsets: IndexSet) {
                Task {
                        await viewModel.deleteCandidate(at: offsets)
                }
        }
}
