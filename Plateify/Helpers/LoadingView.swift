import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    
    // Main brand color - Pantone 280c
    private let brandColor = Color(red: 0, green: 43/255, blue: 127/255) // #002B7F
    
    // Accent colors for animations
    private let accentColors = [
        Color.white.opacity(0.9),
        Color.white.opacity(0.6),
        Color.white.opacity(0.3)
    ]
    
    var body: some View {
        ZStack {
            // Main background
            brandColor
                .ignoresSafeArea()
            
            // Content container
            VStack(spacing: 25) {
                // App name and animation container
                HStack(spacing: 15) {
                    // Static app name
                    Text("Plateify")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    // Animated dots
                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(accentColors[index])
                                .frame(width: 6, height: 6)
                                .offset(y: isAnimating ? -5 : 0)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(0.2 * Double(index)),
                                    value: isAnimating
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(brandColor.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.2), lineWidth: 3)
                        )
                )
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 30)
        }
        .onAppear {
            isAnimating = true
            print("DEBUG: Loading animation started with Pantone 280c background")
        }
    }
}

// MARK: - Preview
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light mode preview
            LoadingView()
                .preferredColorScheme(.light)
            
            // Dark mode preview
            LoadingView()
                .preferredColorScheme(.dark)
        }
    }
}
