import SwiftUI
import PhotosUI

struct OnboardingSexPage: View {
    @Binding var selectedSex: String?
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer(minLength: 24)
            
            Text("Cum te identifici?")
                .font(.title)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
            Text("Ne ajută să personalizăm fiecare detaliu legat de experiența ta in Plateify")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal,30)
                .padding(.bottom, 24)
            
            
            Spacer()
            
            VStack(alignment: .center, spacing: 24) {
                HStack(spacing: 24) {
                    GenderSelectButton(label: "Female", icon: "person", color: .pink, isSelected: selectedSex == "Feminin") {
                        selectedSex = "Feminin"
                    }
                    Text("or")
                        .foregroundColor(.gray)
                        .font(.headline)
                    GenderSelectButton(label: "Male", icon: "person", color: .blue, isSelected: selectedSex == "Masculin") {
                        selectedSex = "Masculin"
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
            
            Spacer()
            
            OnboardingInfoCard(icon: "person", iconColor: .black, title: "Tu ești în centrul experienței", subtitle: "Micile detalii fac diferența într-o experiență cu adevărat a ta")
                .padding(.horizontal)
            
            Spacer()
        }
    }
}