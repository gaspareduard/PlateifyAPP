import SwiftUI
import PhotosUI

struct OnboardingSecondPage: View {
    var body: some View {
        VStack() {
            
            Spacer()
            
            VStack {
                Text("Ce Poți Face cu")
                Text("Plateify ?")
            }
            .font(.title)
            .fontWeight(.heavy)
            
            Text("De la găsirea altor șoferi prietenoși la construirea propriei rețele, Plateify îți oferă o modalitate inedită de a te conecta.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer ()
            
            VStack(spacing: 16) {
                OnboardingInfoCard(
                    icon: "magnifyingglass",
                    iconColor: .blue,
                    title: "Scanează o Plăcuță",
                    subtitle: "Caută numărul de înmatriculare văzut anterior"
                )
                
                OnboardingInfoCard(
                    icon: "bubble.left.and.text.bubble.right.fill",
                    iconColor: .yellow,
                    title: "Începe o Conversatie",
                    subtitle: "Conecteazǎ-te cu utilizaatorii Plateify"
                )
                
                OnboardingInfoCard(
                    icon: "mappin.and.ellipse",
                    iconColor: .red,
                    title: "Șoferi din Apropiere",
                    subtitle: "Descoperă persoane din jurul tău"
                )
                
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}