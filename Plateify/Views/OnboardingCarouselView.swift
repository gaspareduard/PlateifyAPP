import SwiftUI

struct OnboardingCarouselView: View {
    @State private var currentPage = 0
    let totalPages = 5
    @State private var onboardingFirstName = ""
    @State private var onboardingLastName = ""
    @State private var onboardingPlateNumber = ""
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                OnboardingWelcomePage(currentPage: $currentPage)
                    .tag(0)
                OnboardingSecondPage()
                    .tag(1)
                OnboardingProfilePage(firstName: $onboardingFirstName, lastName: $onboardingLastName, plateNumber: $onboardingPlateNumber)
                    .tag(2)
                OnboardingProfilePhotoPage()
                    .tag(3)
                OnboardingPageView(title: "Privacy & Visibility")
                    .tag(4)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .animation(.easeInOut, value: currentPage)
            .frame(maxHeight: .infinity)
            
            // Page indicator and navigation
            VStack(spacing: 12) {
                if currentPage == 0 {
                    Button(action: { withAnimation { currentPage += 1 } }) {
                        Text("Începe Acum")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(24)
                    }
                    .padding(.horizontal)
                } else {
                    HStack {
                        if currentPage > 0 {
                            Button("Înapoi") {
                                withAnimation { currentPage -= 1 }
                            }
                            .padding()
                        }
                        Spacer()
                        if currentPage < totalPages - 1 {
                            Button("Înainte") {
                                withAnimation { currentPage += 1 }
                            }
                            .padding()
                        } else {
                            Button("Finalizează") {
                                // TODO: Mark onboarding as complete and allow access to app
                            }
                            .padding()
                        }
                    }
                    .padding(.horizontal)
                }
                // Dots and page number
                HStack(spacing: 6) {
                    ForEach(0..<totalPages, id: \ .self) { i in
                        Circle()
                            .fill(i == currentPage ? Color.blue : Color(.systemGray4))
                            .frame(width: 8, height: 8)
                    }
                }
                
            }
            .padding(.bottom, 12)
        }
    }
}

struct OnboardingWelcomePage: View {
    @Binding var currentPage: Int
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
            
            Image("Carousel1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300) // Adjust width as needed
                
                
            
            Text("Bun venit la Plateify!")
                .font(.title)
                .fontWeight(.heavy)
                .padding(.top,32)
                .padding(.bottom,8)
            
            Text("Transformă întâlnirile din trafic în conexiuni reale. Descoperă și conversează cu oameni prin intermediul numerelor de înmatriculare.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 24)
            
            Spacer()
            
            NumberPlateAnimationView()
                .padding(.bottom,50)
                
            Spacer()
            
            HStack(spacing: 6) {
                Image(systemName: "shield.fill")
                    .foregroundColor(Color.blue)
                    .font(.caption)
                Text("Confidențialitatea și siguranța ta sunt prioritatea noastră")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal)
    }
}

struct NumberPlateAnimationView: View {
    var body: some View {
        // Placeholder for animated number plate (can be replaced with real animation)
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .frame(width: 180, height: 48)
            .overlay(
                HStack(spacing: 6) {
                    Text("RO")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color(red: 0, green: 0, blue: 139/255))
                        .cornerRadius(2)
                    Text("B 123 ABC")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
            ).shadow(radius: 4)
            
    }
}

struct OnboardingInfoCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundColor(iconColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(Color(.systemGray))
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(height: 80)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

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

struct OnboardingProfilePage: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var plateNumber: String
    @State private var showInfo = false
    @State private var selectedSex: String? = nil
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)
            Text("Creează-ți Profilul")
                .font(.title)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .padding(.bottom, 24)
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
                VStack( spacing: 6) {
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
                }.padding(.top,30)
                // Gender selection
                VStack(alignment: .leading, spacing: 6) {
                    Text("Sex")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    HStack(spacing: 16) {
                        GenderSelectButton(label: "Masculin", icon: "person.fill", isSelected: selectedSex == "Masculin", color: .blue) {
                            selectedSex = "Masculin"
                        }
                        GenderSelectButton(label: "Feminin", icon: "person.fill", isSelected: selectedSex == "Feminin", color: .pink) {
                            selectedSex = "Feminin"
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
            Spacer()
        }
        .alert("Atenție", isPresented: $showInfo) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Trebuie să ai drepturi depline asupra numărului de înmatriculare introdus. Ești responsabil pentru corectitudinea datelor furnizate.")
        }
    }
}

struct GenderSelectButton: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(isSelected ? .white : color)
                Text(label)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : color)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 18)
            .background(isSelected ? color : Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? color : Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OnboardingProfilePhotoPage: View {
    @State private var showInfo = false
    @State private var showMainPhotoPicker = false
    @State private var showPhoto2Picker = false
    @State private var showPhoto3Picker = false
    @State private var mainPhoto: Image? = nil
    @State private var photo2: Image? = nil
    @State private var photo3: Image? = nil
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)
            Text("Adaugă o Poză la Profil")
                .font(.title)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
            Text("Asigură-te că cel puțin o fotografie îți arată clar fața. Pozele cu mașina sunt opționale.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 24)
            // Main photo
            Button(action: { showMainPhotoPicker = true }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 2, dash: [6]))
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(18)
                    VStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .frame(width: 32, height: 28)
                            .foregroundColor(.blue)
                        Text("Fotografie Principală")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Apasă pentru a încărca")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: 180)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            // Extra photos
            HStack(spacing: 16) {
                Button(action: { showPhoto2Picker = true }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 2, dash: [6]))
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(12)
                        VStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("Foto 2")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(height: 80)
                }
                Button(action: { showPhoto3Picker = true }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 2, dash: [6]))
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(12)
                        VStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("Foto 3")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(height: 80)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
            // Guidelines
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("Ghid pentru poze de profil")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                Text("• Asigură-te că fața ta este clar vizibilă în cel puțin o fotografie.")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("• Pozele cu mașina sunt opționale, dar pot ajuta la recunoaștere.")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("• Nu încărca poze necorespunzătoare sau care nu te reprezintă.")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("• Pozele necorespunzătoare pot fi șterse de către administratori.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            Spacer()
        }
    }
}

struct OnboardingPageView: View {
    let title: String
    var body: some View {
        VStack {
            Spacer()
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingCarouselView()
} 
