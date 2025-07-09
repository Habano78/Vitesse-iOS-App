//
//  ServiceTests_Mocks.swift
//  VitesseTests
//
//  Created by Perez William on 09/07/2025.
//

import Foundation
@testable import Vitesse

// Notre fausse classe URLSession qui nous donne un contrôle total sur les réponses réseau.
// Elle doit être `@unchecked Sendable` pour être utilisée par le framework `Testing`.
// MARK: - Infrastructure de Mock (Légèrement améliorée)

class MockURLSession: @unchecked Sendable, URLSessionProtocol {
        var dataToReturn: Data?
        var responseToReturn: URLResponse?
        var errorToThrow: Error?
        
        // "Espion" pour vérifier la dernière requête reçue
        private(set) var lastRequest: URLRequest?
        
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
                lastRequest = request // On enregistre la requête pour pouvoir la vérifier
                
                if let error = errorToThrow {
                        throw error
                }
                guard let data = dataToReturn, let response = responseToReturn else {
                        throw NSError(domain: "MockURLSessionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock non configuré pour le test"])
                }
                return (data, response)
        }
}

// Erreur personnalisée pour simuler des problèmes réseau spécifiques au tests
enum TestNetworkError: Error {
        case connectionLost
}
