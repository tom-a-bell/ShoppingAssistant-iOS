import Foundation
import CoreLocation
import Promises

class LocationManager: NSObject {

    static let shared = LocationManager()

    var currentLocation: Location?

    private let locationManager = CLLocationManager()

    private var authorizationPromise: Promise<CLAuthorizationStatus>?
    private var locationPromise: Promise<CLLocation>?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    var isGeofencingSupported: Bool {
        return CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
    }

    var isGeofencingEnabled: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedAlways
    }

    func initialize() {
        Log.info("Location manager initialized")
        locationManager.allowsBackgroundLocationUpdates = true
    }

    func requestAuthorization() -> Promise<CLAuthorizationStatus> {
        if let authorizationPromise = authorizationPromise { return authorizationPromise }

        authorizationPromise = Promise<CLAuthorizationStatus>.pending()
        locationManager.requestAlwaysAuthorization()

        return authorizationPromise!
    }

    func getCurrentLocation() -> Promise<CLLocation> {
        if let locationPromise = locationPromise { return locationPromise }

        locationPromise = Promise<CLLocation>.pending()
        locationServicesAreAvailable ? locationManager.startUpdatingLocation() : locationManager.requestWhenInUseAuthorization()

        return locationPromise!
    }

    private var locationServicesAreAvailable: Bool {
        let status = CLLocationManager.authorizationStatus()
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }

    func startMonitoring(_ location: Location) {
        let region = self.region(for: location)
        locationManager.startMonitoring(for: region)
    }

    func stopMonitoring(_ location: Location) {
        if let region = monitoredRegion(for: location) {
            locationManager.stopMonitoring(for: region)
        }
    }

    private func monitoredRegion(for location: Location) -> CLRegion? {
        return locationManager.monitoredRegions.first(where: { $0.identifier == location.id.stringValue })
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if let authorizationPromise = authorizationPromise {
            authorizationPromise.fulfill(status)
        }

        guard status == .authorizedWhenInUse || status == .authorizedAlways else { return }

        if locationPromise != nil {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        if let locationPromise = locationPromise {
            locationPromise.fulfill(location)
        }

        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let location = location(for: region) {
            currentLocation = location
            GeofenceService.shared.didEnter(location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let location = location(for: region) {
            currentLocation = nil
            GeofenceService.shared.didExit(location)
        }
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        Log.error("Monitoring failed for region \(region?.identifier ?? "unknown"): \(error.localizedDescription)", error: error)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.error("Location Manager failed: \(error.localizedDescription)", error: error)
    }
}

extension LocationManager {
    func region(for location: Location) -> CLCircularRegion {
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let radius = min(location.radius, locationManager.maximumRegionMonitoringDistance)

        let region = CLCircularRegion(center: center, radius: radius, identifier: location.id.stringValue)

        region.notifyOnEntry = true
        region.notifyOnExit = false

        return region
    }

    func location(for region: CLRegion) -> Location? {
        guard let region = region as? CLCircularRegion, let id = UUID(from: region.identifier) else { return nil }

        let coordinate = Coordinate(latitude: region.center.latitude, longitude: region.center.longitude)
        return Location(id: id, name: "Region", placeId: "", coordinate: coordinate, radius: region.radius)
    }
}
