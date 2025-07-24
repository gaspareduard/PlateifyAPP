import SwiftUI
import PhotosUI

struct OnboardingCarouselView: View {
        @EnvironmentObject private var authVM: AuthenticationViewModel
        @EnvironmentObject private var userSvc: UserService

        @ObservedObject var vm: OnboardingViewModel

        @State private var currentPage = 0
        @State private var showError = false
        private let totalPages = 8

    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                Onboarding0(
                    currentPage: $currentPage)
                    .tag(0)
                OnboardingSecondPage()
                    .tag(1)
                OnboardingProfilePage(
                    firstName: $vm.firstName,
                    lastName: $vm.lastName)
                    .tag(2)
                OnboardingPlatePage(
                    plateNumber: $vm.plateNumber)
                    .tag(3)
                OnboardingSexPage(
                    selectedSex: $vm.sex)
                    .tag(4)
                OnboardingBioPage(
                    bio: $vm.bio,
                    currentPage: $currentPage)
                    .tag(5)
                OnboardingProfilePhotoPage(
                    mainPhoto: $vm.profileImage,
                    mainPhotoData: $vm.imageData)
                    .tag(6)
                OnboardingPrivacyVisibilityPage(
                    allowLocationSharing: $vm.allowLocationSharing)
                    .tag(7)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .animation(.easeInOut, value: currentPage)
            .frame(maxHeight: .infinity)
            
            // Page indicator and navigation

            navigationControls
            
            
        }
        .onChange(of: currentPage) { _ in
            vm.validationErrors.removeAll()
            vm.finalizeError = nil
        }
        .alert("Eroare", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.finalizeError ?? "Unknown error")
        }
    }
    
    
    @ViewBuilder
        private var navigationControls: some View {
            VStack(spacing: 12) {
                if currentPage == 0 {
                    
                    Button {
                        withAnimation { currentPage += 1 }
                    } label: {
                        Text("Începe Acum")
                            .font(.title2)
                            .fontWeight(.semibold )
                            .padding(2)
                    }.buttonStyle(.borderedProminent)
                        .padding(.horizontal)
                        .padding(.bottom,20)

                    
                    
                    
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
                            Button {
                                vm.checkValidation()
                                guard vm.validationErrors.isEmpty else {
                                    showError = true
                                    return
                                }
                                Task {
                                    await vm.finalizeOnboarding()
                                    if vm.finalizeError != nil {
                                        showError = true
                                    }
                                }
                            } label: {
                                if vm.isFinalizing {
                                    ProgressView().frame(maxWidth: .infinity)
                                } else {
                                    Text("Finalizează")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(vm.isFinalizing)
                            .padding()
                        }
                    }
                    .padding(.horizontal)



                    // validation errors
                    if !vm.validationErrors.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(vm.validationErrors, id: \.self) { err in
                                HStack {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text(err)
                                        .font(.footnote)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    if let finalizeError = vm.finalizeError {
                        Text(finalizeError)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                }
                
                if(currentPage != 0 ){
                    
                    HStack(spacing: 6) {
                        ForEach(0..<totalPages, id: \.self) { i in
                            Circle()
                                .fill(i == currentPage ? Color.blue : Color(.systemGray4))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }
            .padding(.bottom, 12)
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


struct OnboardingCarouselView_Previews: PreviewProvider {
  static var previews: some View {
    // Create a “preview” user so our AuthenticationViewModel
    // thinks it’s signed in.
      let previewUser = TestData.user
    
    // The auth VM in preview mode
    let authVM = AuthenticationViewModel(previewUser: previewUser)
    // And inject a real UserService (it won’t actually call Firestore in preview)
    let userSvc = UserService()
    
    // Finally the onboarding VM
    let onboardingVM = OnboardingViewModel(
      authVM: authVM,
      userService: userSvc
    )
    
    // Put it all together
    return OnboardingCarouselView(vm: onboardingVM)
      .environmentObject(authVM)
      .environmentObject(userSvc)
  }
}
