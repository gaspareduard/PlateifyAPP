//
//  CustomCheckbox.swift
//  Plateify
//
//  Created by Eduard Gaspar on 30.03.2025.
//

import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack() {

            RoundedRectangle(cornerRadius: 5.0)
                .stroke(lineWidth: 2)
                .frame(width: 25, height: 25)
                .cornerRadius(5.0)
                .overlay {
                    Image(systemName: configuration.isOn ? "checkmark" : "")
                }
                .onTapGesture {
                    withAnimation(.default) {
                        configuration.isOn.toggle()
                    }
                }

            configuration.label

        }
    }
}
