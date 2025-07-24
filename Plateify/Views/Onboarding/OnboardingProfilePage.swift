import SwiftUI
import PhotosUI
extension OnboardingCarouselView{
    struct OnboardingProfilePage: View {
        @Binding var firstName: String
        @Binding var lastName: String
        var body: some View {
            VStack() {
                Spacer()
                Text("Creează-ți Profilul")
                    .font(.title)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                
                Text("Începe prin a introduce datele tale de bază.\n Acest pas ne ajută să personalizăm experiența ta.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Prenume")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField("Introduceți prenumele", text: $firstName)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4)))
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nume")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField("Introduceți numele", text: $lastName)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4)))
                    }
                }
                .padding(.horizontal)
                
                OnboardingInfoCard(
                    icon: "person.bubble.fill",
                    iconColor: .blue,
                    title: "Cum te cheama ?",
                    subtitle: "Nu-ți face griji,nu vom afișa aceste date public fără acordul tău."
                ).padding(.horizontal)
                    .padding(.vertical,40)
                
                
                Spacer()
            }
        }
    }
}
