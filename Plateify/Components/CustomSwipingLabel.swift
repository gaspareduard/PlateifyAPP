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
        Text("NOPE")
            .font(.title)
            .fontWeight(.heavy)
            .foregroundColor(.red)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.red, lineWidth: 4)
                    .fill(Color.clear)
            )
    }
}

/// A green "Like" label to display behind a swiping card.
struct LikeLabel: View {
    var body: some View {
        Text("LIKE")
            .font(.title)
            .fontWeight(.heavy)
            .foregroundColor(.green)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.green, lineWidth: 4)
                    .fill(Color.clear)
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
