import CoreLocation

@globalActor
actor LocationActor {
  static let shared = LocationActor()

  private let manager = CLLocationManager()

  init() {
    manager.desiredAccuracy = kCLLocationAccuracyBest
    // …and don’t forget to set its delegate somewhere if you need updates…
  }

  /// Ask for “When In Use” permissions
  func requestLocationAuthorization() {
    manager.requestWhenInUseAuthorization()
  }

  /// Read-only snapshot of the last known location
  var currentLocation: CLLocation? {
    manager.location
  }

  /// The current permission status
  var authorizationStatus: CLAuthorizationStatus {
    manager.authorizationStatus
  }
}
