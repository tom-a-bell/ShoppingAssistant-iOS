import Foundation
import CoreLocation

protocol MapViewModelDelegate {
    func enableCurrentLocation()
    func centreMapOn(_ location: CLLocation)
}

class MapViewModel: NSObject {

    public var delegate: MapViewModelDelegate?

    private let locationManager = CLLocationManager()

    public func onViewDidLoad() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
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
