import SwiftUI
import PhotosUI

struct OnboardingPlatePage: View {
    @Binding var plateNumber: String
    @State private var showInfo = false
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)
            Text("Număr de Înmatriculare")
                .font(.title)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
            
            Text("Introdu numărul tău de înmatriculare pentru a fi recunoscut de alți utilizatori în trafic.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 24)
            
            Spacer()
            
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Spacer()
                    Text("Număr de Înmatriculare")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                        .onTapGesture { showInfo = true }
                    Spacer()
                }
                NumberPlateInputView(plateNumber: $plateNumber)
                    .padding(.vertical, 2)
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
            
            Spacer()
            
            OnboardingInfoCard(
                icon: "car.fill",
                iconColor: .blue,
                title: "Primul număr de înmatriculare",
                subtitle: "Ulterior poți introduce mai multe numere de înmatriculare"
            ).padding(.horizontal)
            
            Spacer()
        }
        .alert("Atenție", isPresented: $showInfo) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Trebuie să ai drepturi depline asupra numărului de înmatriculare introdus. Ești responsabil pentru corectitudinea datelor furnizate.")
        }
        
        
        
        
        
        
    }
}