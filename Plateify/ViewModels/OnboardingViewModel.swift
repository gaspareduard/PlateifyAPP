import Foundation
import CoreLocation
import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    // MARK: – Published for binding
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var plateNumber = ""
    @Published var sex: String? = nil
    @Published var bio = ""
    @Published var profileImage: Image?
    @Published var imageData: Data?
    @Published var allowLocationSharing = false {
        didSet { Task { await toggleLocationSharing() } }
    }
    @Published var acquiredLocation: CLLocation?
    @Published var isFinalizing = false
    @Published var validationErrors: [String] = []
    @Published var finalizeError: String?

    // MARK: – Dependencies
    private let authVM: AuthenticationViewModel
    private let userService: UserService
    private let locationActor: LocationActor

    // MARK: – Init
    init(
        authVM: AuthenticationViewModel,
        userService: UserService = UserService(),
        locationActor: LocationActor = .shared
    ) {
        self.authVM = authVM
        self.userService = userService
        self.locationActor = locationActor
    }

    // MARK: – Validation
    private func validate() -> [String] {
        guard let user = authVM.user else {
            return ["Utilizatorul nu este autentificat"]
        }
        var errs = [String]()
        if firstName.trimmingCharacters(in: .whitespaces).isEmpty { errs.append("Prenumele este obligatoriu") }
        if lastName.trimmingCharacters(in: .whitespaces).isEmpty  { errs.append("Numele este obligatoriu") }
        if plateNumber.trimmingCharacters(in: .whitespaces).isEmpty { errs.append("Numărul de înmatriculare este obligatoriu") }
        if sex == nil { errs.append("Selectează sexul") }
        if imageData == nil { errs.append("Adaugă o poză de profil") }
        if !allowLocationSharing { errs.append("Activează partajarea locației") }
        else if acquiredLocation == nil { errs.append("Se așteaptă obținerea locației") }
        return errs
    }

    func checkValidation() {
        validationErrors = validate()
    }

    // MARK: – Location
    private func toggleLocationSharing() async {
        if allowLocationSharing {
            await locationActor.requestLocationAuthorization()
            // once authorized, get the current location
            if let loc = await locationActor.currentLocation {
                acquiredLocation = loc
            }
        } else {
            acquiredLocation = nil
        }
    }

    // MARK: – Finalize
    func finalizeOnboarding() async {
        validationErrors = []
        finalizeError = nil

        // 1) validate form
        let errs = validate()
        guard errs.isEmpty else {
            validationErrors = errs
            return
        }

        guard var user = authVM.user else {
            finalizeError = "Utilizatorul nu este autentificat"
            return
        }

        isFinalizing = true
        defer { isFinalizing = false }

        // 2) upload photo
        if let data = imageData, let uid = user.id {
            do {
                let url = try await userService.uploadProfileImage(data, userId: uid)
                user.profileImageURL = url.absoluteString
            } catch {
                finalizeError = "Eroare la încărcarea pozei: \(error.localizedDescription)"
                return
            }
        }

        // 3) update user object
        user.firstName = firstName.trimmingCharacters(in: .whitespaces)
        user.lastName  = lastName.trimmingCharacters(in: .whitespaces)
        
        let raw = plateNumber.trimmingCharacters(in: .whitespaces)
        let norm = raw.normalizedPlate
        user.plateNumbers = [norm]
        
        user.sex     = sex!
        user.bio     = bio.isEmpty ? nil : bio.trimmingCharacters(in: .whitespaces)
        user.hasCompletedOnboarding = true
        if let loc = acquiredLocation {
            user.latitude = loc.coordinate.latitude
            user.longitude = loc.coordinate.longitude
        }

        // 4) persist
        do {
            try await userService.updateUser(user)
            authVM.updateUser(user)
            
        } catch {
            finalizeError = "Eroare la salvare: \(error.localizedDescription)"
        }
    }
}
