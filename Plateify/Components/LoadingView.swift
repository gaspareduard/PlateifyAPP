//
//  LoadingView.swift
//  Plateify
//
//  Created by Eduard Gaspar on 23.05.2025.
//


import SwiftUI
import FirebaseAuth

private struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}