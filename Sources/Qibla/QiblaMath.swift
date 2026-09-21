import CoreLocation

enum QiblaMath {
    // The Kaaba, Mecca — fixed, well-known coordinates.
    static let kaaba = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)

    static func bearing(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> Double {
        let lat1 = origin.latitude * .pi / 180
        let lon1 = origin.longitude * .pi / 180
        let lat2 = destination.latitude * .pi / 180
        let lon2 = destination.longitude * .pi / 180

        let deltaLon = lon2 - lon1
        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        let bearing = atan2(y, x) * 180 / .pi
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }

    static func distanceKm(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> Double {
        let earthRadiusKm = 6371.0
        let lat1 = origin.latitude * .pi / 180
        let lat2 = destination.latitude * .pi / 180
        let deltaLat = (destination.latitude - origin.latitude) * .pi / 180
        let deltaLon = (destination.longitude - origin.longitude) * .pi / 180

        let a = sin(deltaLat / 2) * sin(deltaLat / 2)
            + cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadiusKm * c
    }

    static func compassLabel(forDegrees degrees: Double) -> String {
        let directions = ["Kuzey", "Kuzeydoğu", "Doğu", "Güneydoğu", "Güney", "Güneybatı", "Batı", "Kuzeybatı"]
        let index = Int((degrees + 22.5) / 45) % 8
        return directions[index]
    }
}
