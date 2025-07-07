//
//  EmailValidation.swift
//  VitesseTests
//
//  Created by Perez William on 07/07/2025.
//

import Foundation

extension String {
        var isValidEmail: Bool {
                // Expression régulière simple et courante pour la validation d'email
                let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
                return emailPred.evaluate(with: self)
        }
        
        var isValidPhoneNumber: Bool {
                // Supprime les espaces pour ne garder que les chiffres
                let cleanedNumber = self.replacingOccurrences(of: " ", with: "")
                // Vérifie que la chaîne n'est pas vide et que tous les caractères sont des chiffres
                return !cleanedNumber.isEmpty && cleanedNumber.allSatisfy { $0.isNumber }
        }
}
