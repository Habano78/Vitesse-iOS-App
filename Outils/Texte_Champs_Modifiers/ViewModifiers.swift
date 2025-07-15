//
//  ViewModifiers.swift
//  Vitesse
//
//  Created by Perez William on 15/07/2025.
//

import Foundation
import SwiftUI

//MARK: ViewModifier afin d'uniformiser les TextFields

struct StandardTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.plain)
            .padding(12)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
    }
}

// 2. On crée une extension pour l'appeler plus facilement
extension View {
    func standardTextFieldStyle() -> some View {
        self.modifier(StandardTextFieldModifier())
    }
}
