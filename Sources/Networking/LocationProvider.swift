import CoreLocation

@MainActor
final class LocationProvider: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var coordinate: CLLocationCoordinate2D?

    // Istanbul fallback, used if location permission is denied or resolution times out.
    static let fallback = CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
}

extension LocationProvider: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate else { return }
        Task { @MainActor in
            self.coordinate = coordinate
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // HomeView falls back to the Istanbul coordinate after a short timeout regardless.
    }
}
