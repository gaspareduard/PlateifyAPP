import SwiftUI
import PhotosUI

struct OnboardingCarouselView: View {
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    @StateObject private var onboardingVM = OnboardingViewModel()
    @State private var currentPage = 0
    let totalPages = 8
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                OnboardingWelcomePage(currentPage: $currentPage)
                    .tag(0)
                OnboardingSecondPage()
                    .tag(1)
                OnboardingProfilePage(firstName: $onboardingVM.firstName, lastName: $onboardingVM.lastName)
                    .tag(2)
                OnboardingPlatePage(plateNumber: $onboardingVM.plateNumber)
                    .tag(3)
                OnboardingSexPage(selectedSex: $onboardingVM.sex)
                    .tag(4)
                OnboardingBioPage(bio: $onboardingVM.bio, currentPage: $currentPage)
                    .tag(5)
                OnboardingProfilePhotoPage(mainPhoto: $onboardingVM.mainProfilePhoto, mainPhotoData: $onboardingVM.mainProfilePhotoData)
                    .tag(6)
                OnboardingPrivacyVisibilityPage(allowLocationSharing: $onboardingVM.allowLocationSharing)
                    .tag(7)
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
                            Button(action: {
                                if onboardingVM.canFinalize(currentUser: authViewModel.user) {
                                    Task { await onboardingVM.finalizeOnboarding(authViewModel: authViewModel) }
                                } else {
                                    onboardingVM.showValidationError = true
                                }
                            }) {
                                if onboardingVM.isFinalizing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Text("Finalizează")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding()
                            .background(onboardingVM.canFinalize(currentUser: authViewModel.user) ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .disabled(!onboardingVM.canFinalize(currentUser: authViewModel.user) || onboardingVM.isFinalizing)
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
                // Validation error message
                if onboardingVM.showValidationError && !onboardingVM.canFinalize(currentUser: authViewModel.user) {
                    Text("Te rugăm să completezi toate câmpurile obligatorii și să adaugi o poză de profil.")
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
                if let error = onboardingVM.finalizeError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
            .padding(.bottom, 12)
        }
    }
}

#if canImport(UIKit)
extension Image {
    func asUIImage() -> UIImage? {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let uiImage = child.value as? UIImage {
                return uiImage
            }
        }
        return nil
    }
}
#endif

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

struct OnboardingProfilePhotoPage: View {
    @Binding var mainPhoto: Image?
    @Binding var mainPhotoData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)
            Text("Adaugă o Poză la Profil")
                .font(.title)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
            Text("Asociazā-ți numarul de inmatriculare cu o poza de profil care te defineste.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 24)
            // Main photo
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 2, dash: [6]))
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(18)
                    if let mainPhoto = mainPhoto {
                        mainPhoto
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .resizable()
                                .frame(width: 32, height: 28)
                                .foregroundColor(.blue)
                            Text("Fotografie de profil")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Apasă pentru a încărca")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(height: 180)
            }
            .onChange(of: selectedPhotoItem) { newItem in
                if let newItem {
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            mainPhoto = Image(uiImage: uiImage)
                            mainPhotoData = data
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            // Guidelines
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("Ghid pentru poze de profil")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            Spacer()
        }
    }
}

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

// Custom gender select button matching the provided design


#Preview {
    let mockAuthVM = AuthenticationViewModel()
    mockAuthVM.user = TestData.testUser
    return OnboardingCarouselView()
        .environmentObject(mockAuthVM)
}

