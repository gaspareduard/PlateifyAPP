import SwiftUI
import PhotosUI

struct OnboardingBioPage: View {
    @Binding var bio: String
    @Binding var currentPage: Int
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)
            Text("Scrie ceva despre tine")
                .font(.title)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
            
            Text(" Adaugă o descriere, nu e obligatoriu, dar ajută să te conectezi cu ceilalți.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 24)

            
            Spacer()
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Bio")
                    .font(.subheadline)
                    .fontWeight(.medium)
                TextEditor(text: $bio)
                    .frame(height: 120)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4)))
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
            Button("Sari peste") {
                currentPage += 1
            }
            .padding(.top, 8)
            Spacer()
        }
    }
}