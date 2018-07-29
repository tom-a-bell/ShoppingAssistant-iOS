import Foundation
import CoreLocation

protocol MapViewModelDelegate {
    func enableCurrentLocation()
    func centreMapOn(_ location: CLLocation)
    func markPlaces(_ places: [GooglePlace])
}

class MapViewModel: NSObject {

    public var delegate: MapViewModelDelegate?

    private let locationManager = CLLocationManager()

    private let searchTypes = ["grocery_or_supermarket"]
    private let searchRadius: Double = 1000

    public func onViewDidLoad() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    public func findNearbyPlaces(coordinate: CLLocationCoordinate2D) {
        GoogleMapsService.shared.getNearbyPlaces(coordinate: coordinate, radius: searchRadius, types: searchTypes)
            .then { places in
                self.delegate?.markPlaces(places)
            }.catch { error in
                print(error)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }

        locationManager.startUpdatingLocation()
        delegate?.enableCurrentLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        delegate?.centreMapOn(location)
        locationManager.stopUpdatingLocation()
    }
}
