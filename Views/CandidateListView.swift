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
                        VStack {
                                List {
                                       
                                        ForEach(viewModel.candidates) { candidate in
                                                ZStack {
                                                        HStack {
                                                                Text("\(candidate.firstName) \(candidate.lastName)")
                                                                Spacer()
                                                                if candidate.isFavorite {
                                                                        Image(systemName: "star.fill")
                                                                                .foregroundColor(.yellow)
                                                                }
                                                        }

                                                        NavigationLink(destination: CandidateDetailView(candidate: candidate, isAdmin: self.isAdmin)) {
                                                                ///  contenu est vide pour être invisible
                                                                EmptyView()
                                                        }
                                                        .opacity(0) // On le rend complètement transparent
                                                }
                                                .padding(.vertical, 8)
                                        }
                                        .onDelete(perform: delete)
                                        .onDelete(perform: delete)
                                }
                                .navigationDestination(for: Candidate.self) { selectedCandidate in
                                        CandidateDetailView(candidate: selectedCandidate, isAdmin: self.isAdmin)
                                }
                        }
                        
                        .listStyle(.insetGrouped)
                        // Bouton Logout ici
                        Button("Logout", role: .destructive) {
                                onLogout()
                        }
                        .padding()
                        .navigationTitle("Candidats")
                        .navigationBarTitleDisplayMode(.inline)
                        .searchable(text: $viewModel.searchText, prompt: "Search")
                        .toolbar {
                                ToolbarItemGroup(placement: .topBarLeading) {
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
