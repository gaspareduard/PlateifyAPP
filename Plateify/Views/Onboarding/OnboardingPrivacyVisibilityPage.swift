import SwiftUI
import PhotosUI

struct OnboardingPrivacyVisibilityPage: View {
    @Binding var allowLocationSharing: Bool
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)
            Text("Privacy & Visibility")
                .font(.title)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
            Text("Permite partajarea locației pentru a primi recomandări bazate pe apropiere. Poți schimba această opțiune oricând din setări.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 24)
            Spacer()
            HStack(alignment: .center, spacing: 12) {
                Button(action: { allowLocationSharing.toggle() }) {
                    Image(systemName: allowLocationSharing ? "checkmark.square.fill" : "square")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(allowLocationSharing ? .blue : .gray)
                }
                Text("Sunt de acord să partajez locația pentru recomandări bazate pe apropiere.")
                    .font(.body)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 16)
            .padding(.horizontal)
            Spacer()
        }
    }
}