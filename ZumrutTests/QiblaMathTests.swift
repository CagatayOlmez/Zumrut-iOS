import CoreLocation
import XCTest
@testable import Zumrut

final class QiblaMathTests: XCTestCase {
    private let istanbul = CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)

    func testBearingFromIstanbulToKaaba() {
        // Reference value computed independently via the standard great-circle
        // initial-bearing formula (haversine bearing), not derived from QiblaMath itself.
        let bearing = QiblaMath.bearing(from: istanbul, to: QiblaMath.kaaba)
        XCTAssertEqual(bearing, 151.62, accuracy: 0.1)
    }

    func testDistanceFromIstanbulToKaaba() {
        let distance = QiblaMath.distanceKm(from: istanbul, to: QiblaMath.kaaba)
        XCTAssertEqual(distance, 2405.07, accuracy: 1.0)
    }

    func testDistanceBetweenSamePointIsZero() {
        XCTAssertEqual(QiblaMath.distanceKm(from: QiblaMath.kaaba, to: QiblaMath.kaaba), 0, accuracy: 0.0001)
    }

    func testBearingDueEastOnEquator() {
        let origin = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let destination = CLLocationCoordinate2D(latitude: 0, longitude: 10)
        XCTAssertEqual(QiblaMath.bearing(from: origin, to: destination), 90, accuracy: 0.01)
    }

    func testBearingIsAlwaysWithinValidRange() {
        let points: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 89, longitude: 179),
            CLLocationCoordinate2D(latitude: -89, longitude: -179),
            CLLocationCoordinate2D(latitude: 0, longitude: 0),
        ]
        for point in points {
            let bearing = QiblaMath.bearing(from: point, to: QiblaMath.kaaba)
            XCTAssertGreaterThanOrEqual(bearing, 0)
            XCTAssertLessThan(bearing, 360)
        }
    }

    func testCompassLabelCardinalDirections() {
        XCTAssertEqual(QiblaMath.compassLabel(forDegrees: 0), "Kuzey")
        XCTAssertEqual(QiblaMath.compassLabel(forDegrees: 90), "Doğu")
        XCTAssertEqual(QiblaMath.compassLabel(forDegrees: 180), "Güney")
        XCTAssertEqual(QiblaMath.compassLabel(forDegrees: 270), "Batı")
    }

    func testCompassLabelBoundary() {
        XCTAssertEqual(QiblaMath.compassLabel(forDegrees: 20), "Kuzey")
        XCTAssertEqual(QiblaMath.compassLabel(forDegrees: 25), "Kuzeydoğu")
    }
}
