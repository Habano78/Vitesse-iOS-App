//
//  Business_Models.swift
//  Vitesse
//
//  Created by Perez William on 30/06/2025.
//

import Foundation

struct Candidate: Identifiable, Hashable {
       //MARK: Propriétés
        let id: UUID
        let firstName: String
        let lastName: String
        let email: String
        let phone: String?
        let note: String?
        let linkedinURL: String?
        var isFavorite: Bool
        
        // MARK: - Init from DTO
        init(from dto: CandidateResponseDTO) {
                self.id = dto.id
                self.firstName = dto.firstName
                self.lastName = dto.lastName
                self.email = dto.email
                self.phone = dto.phone
                self.note = dto.note
                self.linkedinURL = dto.linkedinURL
                self.isFavorite = dto.isFavorite
        }
}
