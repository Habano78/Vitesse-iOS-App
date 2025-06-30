//
//  DTOs_Models.swift
//  Vitesse
//
//  Created by Perez William on 30/06/2025.
//

import Foundation

// Envoyer le corps de la requête pour l'authentification(POST /user/auth)
struct AuthRequestDTO: Codable {
        let username: String
        let password: String
}

// Réponse du serveur après une connexion réussie(POST /user/auth)
struct AuthResponseDTO: Codable {
        let isAdmin: Bool
        let token: String
}

import Foundation

// Envoyer requête pour créer ou mettre à jour un candidat(POST /candidate & PUT /candidate/:candidateId)
struct CandidatePayloadDTO: Codable {
        let firstName: String
        let lastName: String
        let email: String
        let phone: String?
        let note: String?
        let linkedinURL: String?
}

import Foundation

// Réponse du serveur lorsqu'il renvoie les informations d'un candidat(GET, POST, et PUT sur /candidate)
struct CandidateResponseDTO: Codable, Identifiable {
        let id: UUID
        let firstName: String
        let lastName: String
        let email: String
        let phone: String?
        let note: String?
        let linkedinURL: String?
        let isFavorite: Bool
}
