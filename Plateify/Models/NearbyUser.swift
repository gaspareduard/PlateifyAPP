import Foundation
import FirebaseFirestore
import SwiftUI
import CoreLocation

struct NearbyUser: Identifiable, Codable {
    @DocumentID var id: String?
    var profileImageURL: String?
    var plateNumbers: [String]
    var firstName: String
    var age: Int?
    var bio: String?
    var latitude: Double?
    var longitude: Double?

    var name: String { firstName }

    func distance(from currentLocation: CLLocation?) -> Int? {
        guard
            let lat = latitude,
            let lon = longitude,
            let current = currentLocation
        else { return nil }

        let userLoc = CLLocation(latitude: lat, longitude: lon)
        return Int(userLoc.distance(from: current) / 1000)
    }
}
