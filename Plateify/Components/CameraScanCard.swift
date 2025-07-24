import SwiftUI

struct CameraScanCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.blue)
                .frame(height: 160)
            VStack(spacing: 12) {
                Image(systemName: "camera.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .foregroundColor(.white)
                Text("Scanează numărul cu camera")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("Cel mai rapid mod de căutare")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .shadow(color: Color.blue.opacity(0.08), radius: 8, x: 0, y: 4)
    }
} 

#Preview {
    CameraScanCard()
}

