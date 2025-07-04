//
//  JSONEncoderProtocol.swift
//  AuraTests
//
//  Created by Perez William

import Foundation

//MARK: Protocole pour tester le cas requestEncodingFailed
protocol JSONEncoderProtocol {
    func encode<T: Encodable>(_ value: T) throws -> Data
}
// On fait conformer la vraie classe JSONEncoder d'Apple à notre protocole.
// Cela nous permet de l'utiliser par défaut dans notre application.
extension JSONEncoder: JSONEncoderProtocol {}
