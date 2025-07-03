//
//  CandidateListView.swift
//  Vitesse
//
//  Created by Perez William on 01/07/2025.
//
import SwiftUI
import Foundation

struct CandidateListView: View {
        
        // MARK: - Properties
        
        // la vue crée et conserve une instance du ViewModel
        @StateObject private var viewModel = CandidateListViewModel()
        
        // MARK: - Body
        
        var body: some View {
                NavigationStack {
                        // Le contenu de la vue change en fonction de l'état du ViewModel.
                        Group {
                                if viewModel.isLoading {
                                        // 1. État de chargement
                                        ProgressView()
                                } else if let errorMessage = viewModel.errorMessage {
                                        // 2. État d'erreur
                                        VStack(spacing: 10) {
                                                Text("Une erreur est survenue")
                                                        .font(.headline)
                                                Text(errorMessage)
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                        }
                                } else if viewModel.candidates.isEmpty {
                                        
                                        Text("Aucun candidat pour le moment.")
                                                .foregroundColor(.secondary)
                                } else {
                                        
                                        List {
                                                ForEach(viewModel.candidates) { candidate in
                                                        NavigationLink(destination: CandidateDetailView(candidate: candidate)) {
                                                                Text("\(candidate.firstName) \(candidate.lastName)")
                                                        }
                                                }
                                                .onDelete(perform: { offsets in
                                                        Task {
                                                                await viewModel.deleteCandidate(at: offsets)
                                                        }
                                                })
                                        }
                                        .searchable(text: $viewModel.searchText, prompt: "Rechercher un candidat...")
                                        
                                }
                        }
                        .navigationTitle("Candidats")
                        .toolbar { // Filtrage par favoris
                                ToolbarItem(placement: .navigationBarTrailing) {
                                        Button {
                                                
                                                viewModel.isFavoritesFilterActive.toggle()
                                        } label: {
                                                
                                                Image(systemName: viewModel.isFavoritesFilterActive ? "star.fill" : "star")
                                                        .foregroundColor(.yellow)
                                        }
                                }
                        }
                        .onAppear {
                                // Lorsque la vue apparaît, on demande au ViewModel de charger les données.
                                Task {
                                        await viewModel.fetchCandidates()
                                }
                        }
                }
        }
}
