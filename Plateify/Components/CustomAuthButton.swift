//
//  CustomAuthButton.swift
//  Plateify
//
//  Created by Eduard Gaspar on 28.03.2025.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    
    var primaryColor: Color
    var accentColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity,maxHeight: 60)
            .foregroundColor(Color(primaryColor))
            .font(.title3)
            .bold()
            .background(Color(accentColor))
            .cornerRadius(10)
            .frame(height: 60)
            .opacity(configuration.isPressed ? 0.4 : 1.0)
    }
    
}
