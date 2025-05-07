//
//  CustomProfileTabMenu.swift
//  Plateify
//
//  Created by Eduard Gaspar on 07.05.2025.
//

import SwiftUI

extension ProfileView {
    struct ProfileTabItem: View {
        let icon: String
        let label: String
        let color: Color
        let destination: AnyView
        var body: some View {
            NavigationLink(destination: destination) {
                HStack(spacing: 16) {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .frame(width: 24, height: 24)
                    Text(label)
                        .font(.body)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }
        }
    }
    
    
    
    
}
