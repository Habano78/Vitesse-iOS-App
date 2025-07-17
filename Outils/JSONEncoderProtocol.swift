//
//  JSONEncoderProtocol.swift
//  Vitesse
//
//  Created by Perez William on 02/07/2025.
//

import Foundation

//MARK: Protocole pour tester le cas requestEncodingFailed
protocol JSONEncoderProtocol {
    func encode<T: Encodable>(_ value: T) throws -> Data
}

// On fait conformer la vraie classe JSONEncoder d'Apple au protocole.
// Cela permet de l'utiliser par défaut dans notre application.
extension JSONEncoder: JSONEncoderProtocol {}
