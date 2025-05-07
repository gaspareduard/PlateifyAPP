//
//  GenderSelectCustomButton.swift
//  Plateify
//
//  Created by Eduard Gaspar on 07.05.2025.
//

import SwiftUI

struct GenderSelectButton: View {
    let label: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isSelected ? color : Color(.systemGray4), lineWidth: isSelected ? 3 : 1)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                        )
                        .frame(width: 70, height: 70)
                        .shadow(color: isSelected ? color.opacity(0.15) : .clear, radius: 6, x: 0, y: 2)
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(color)
                }
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    GenderSelectButton(label: "Male", icon: "circle.fill", color: .blue, isSelected: true) { }
}