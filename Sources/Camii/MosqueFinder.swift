import CoreLocation
import MapKit

@MainActor
final class MosqueFinder: NSObject, ObservableObject {
    @Published var mosques: [MKMapItem] = []
    @Published var isSearching = false

    func search(near coordinate: CLLocationCoordinate2D) async {
        isSearching = true
        defer { isSearching = false }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "cami"
        request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 8000, longitudinalMeters: 8000)
        request.resultTypes = .pointOfInterest

        do {
            let response = try await MKLocalSearch(request: request).start()
            mosques = response.mapItems
        } catch {
            mosques = []
        }
    }
}
