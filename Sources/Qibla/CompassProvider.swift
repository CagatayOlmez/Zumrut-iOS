import CoreLocation

@MainActor
final class CompassProvider: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var headingDegrees: Double = 0
    @Published var coordinate: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            manager.startUpdatingHeading()
        }
    }

    func stop() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }
}

extension CompassProvider: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let value = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        Task { @MainActor in
            self.headingDegrees = value
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate else { return }
        Task { @MainActor in
            self.coordinate = coordinate
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Fall back to Istanbul so the compass still renders something useful.
        Task { @MainActor in
            if self.coordinate == nil {
                self.coordinate = LocationProvider.fallback
            }
        }
    }
}
