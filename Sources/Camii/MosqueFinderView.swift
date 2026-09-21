import CoreLocation
import MapKit
import SwiftUI

struct MosqueFinderView: View {
    @StateObject private var location = LocationProvider()
    @StateObject private var finder = MosqueFinder()
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        VStack(spacing: 0) {
            Text("Yakındaki Camiler")
                .font(ZumrutFont.display(20))
                .foregroundColor(ZumrutColors.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)

            Map(position: $cameraPosition) {
                ForEach(Array(finder.mosques.enumerated()), id: \.offset) { _, item in
                    Marker(item.name ?? "Cami", coordinate: item.placemark.coordinate)
                        .tint(ZumrutColors.teal)
                }
                UserAnnotation()
            }
            .frame(height: 200)

            Group {
                if finder.isSearching {
                    ProgressView().tint(ZumrutColors.teal).padding()
                } else if finder.mosques.isEmpty {
                    Text("Yakında cami bulunamadı.")
                        .font(ZumrutFont.body(13))
                        .foregroundColor(ZumrutColors.muted)
                        .padding()
                } else {
                    List(Array(finder.mosques.enumerated()), id: \.offset) { _, item in
                        Button {
                            item.openInMaps()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(item.name ?? "Cami")
                                        .font(ZumrutFont.body(14, weight: .semibold))
                                        .foregroundColor(ZumrutColors.ink)
                                    if let distance = distanceText(to: item) {
                                        Text(distance)
                                            .font(ZumrutFont.mono(11))
                                            .foregroundColor(ZumrutColors.muted)
                                    }
                                }
                                Spacer()
                                Image(systemName: "arrow.triangle.turn.up.right.circle")
                                    .foregroundColor(ZumrutColors.teal)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .background(ZumrutColors.paper)
        .task {
            location.requestLocation()
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            let coordinate = location.coordinate ?? LocationProvider.fallback
            cameraPosition = .region(MKCoordinateRegion(center: coordinate, latitudinalMeters: 6000, longitudinalMeters: 6000))
            await finder.search(near: coordinate)
        }
    }

    private func distanceText(to item: MKMapItem) -> String? {
        let userCoordinate = location.coordinate ?? LocationProvider.fallback
        let userLoc = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let itemLoc = CLLocation(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)
        let distanceKm = userLoc.distance(from: itemLoc) / 1000
        return String(format: "%.1f km", distanceKm)
    }
}
