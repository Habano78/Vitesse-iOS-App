//
//  AuthTokenPersistance.swift
//  Vitesse
//
//  Created by Perez William on 01/07/2025.
//

import Foundation
import Security

// La classe se conforme maintenant au protocole
class AuthTokenPersistence: AuthTokenPersistenceProtocol {
    private let keychainService: KeychainInterface
    private let tokenLabel = "com.vitesse.authToken" // Clé unique pour le token

    init(keychainService: KeychainInterface = KeychainService()) {
        self.keychainService = keychainService
    }

    func saveToken(_ token: String) throws {
        guard let tokenData = token.data(using: .utf8) else {
            struct TokenConversionError: Error {}
            throw TokenConversionError()
        }
        let attributes: [String: Any] = [kSecValueData as String: tokenData]
        try keychainService.save(label: tokenLabel, attributes: attributes)
    }

    func retrieveToken() throws -> String? {
        do {
            let item = try keychainService.retrieve(label: tokenLabel, queryAttributes: [:])
            guard let tokenData = item[kSecValueData as String] as? Data,
                  let tokenString = String(data: tokenData, encoding: .utf8) else {
                throw KeychainService.KeychainError.unexpectedData
            }
            return tokenString
        } catch KeychainService.KeychainError.itemNotFound {
            return nil
        }
    }

    func deleteToken() throws {
        try keychainService.delete(label: tokenLabel)
    }
}
