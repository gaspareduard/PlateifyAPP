import Foundation
import CoreLocation

@MainActor
class HomeViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded([NearbyUser])
        case error(String)
    }

    @Published var state: ViewState = .loading
    @Published private(set) var nearbyUsers: [NearbyUser] = []

    private let nearbyService: NearbyUserService
    private let friendService:  FriendService
    private let locationManager: CLLocationManager

    init(
        nearbyService: NearbyUserService,
        friendService:  FriendService,
        locationManager: CLLocationManager = CLLocationManager())
    {
        self.nearbyService  = nearbyService
        self.friendService  = friendService
        self.locationManager = locationManager
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    /// Load nearby users, excluding friends & pending requests
    func loadUsers() async {
        state = .loading
        nearbyUsers = [] // Clear current users while loading

        // grab your two arrays
        let friends  = friendService.friends
        let pending  = friendService.pendingRequests
        let location = locationManager.location

        do {
            // this API returns [NearbyUser]
            let users = try await nearbyService.fetchNearbyUsers(
                excluding: friends,
                pendingRequests: pending,
                location: location
            )
            nearbyUsers = users // Update the published property
            state = .loaded(users)
        } catch {
            state = .error(error.localizedDescription)
            nearbyUsers = [] // Clear users on error
        }
    }

    /// Remove the top user
    func skipUser() {
        guard !nearbyUsers.isEmpty else { return }
        nearbyUsers.removeFirst()
        state = .loaded(nearbyUsers)
    }

    /// Send friend request to the top user, then reload
    func likeUser() async {
        guard let first = nearbyUsers.first,
              let id = first.id
        else { return }

        do {
            try await friendService.sendFriendRequest(to: id)
            await loadUsers()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
