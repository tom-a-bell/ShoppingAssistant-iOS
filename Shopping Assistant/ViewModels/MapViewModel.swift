import Foundation
import CoreLocation

protocol MapViewModelDelegate: ActivityIndicatable, ErrorPresentable {
    func enableCurrentLocation()
    func centreMapOn(_ location: CLLocation)
    func markPlaces(_ places: [GooglePlace])
}

class MapViewModel: NSObject {

    public var delegate: MapViewModelDelegate?

    public var mapCentre: CLLocation?

    private let locationManager = CLLocationManager()

    init(centredAt location: CLLocation? = nil) {
        mapCentre = location
    }

    public func onViewDidLoad() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        if let location = mapCentre {
            delegate?.centreMapOn(location)
        }
    }

    public func mapDidCentreAt(_ location: CLLocation) {
        mapCentre = location
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

        locationManager.stopUpdatingLocation()
        delegate?.centreMapOn(mapCentre ?? location)
    }
}
