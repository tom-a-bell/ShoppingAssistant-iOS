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

    init(centredAt location: CLLocation? = nil) {
        mapCentre = location
    }

    public func onViewDidLoad() {
        if let location = mapCentre {
            delegate?.centreMapOn(location)
        }

        LocationManager.shared.getCurrentLocation()
            .then(updateCurrentLocation)
            .catch(handleError)
    }

    public func mapDidCentreAt(_ location: CLLocation) {
        mapCentre = location
    }

    private func updateCurrentLocation(location: CLLocation) {
        delegate?.centreMapOn(mapCentre ?? location)
        delegate?.enableCurrentLocation()
    }

    private func handleError(error: Error) {
        delegate?.showError(error)
    }
}
