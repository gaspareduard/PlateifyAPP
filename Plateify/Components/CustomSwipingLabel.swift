//
//  CustomLikeDislike.swift
//  Plateify
//
//  Created by Eduard Gaspar on 17.05.2025.
//

import SwiftUI

/// A red "Skip" label to display behind a swiping card.
struct SkipLabel: View {
    var body: some View {
        Text("SKIP")
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.red)
            )
    }
}

/// A green "Like" label to display behind a swiping card.
struct LikeLabel: View {
    var body: some View {
        Text("LIKE")
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.green)
            )
    }
}

// MARK: - Preview
struct SwipeActionLabels_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            LikeLabel()
            SkipLabel()
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
