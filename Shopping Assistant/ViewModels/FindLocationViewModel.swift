import Foundation

class FindLocationViewModel: MapViewModel {

    override public func onViewDidLoad() {
        super.onViewDidLoad()
        findNearbyPlaces()
    }

    private let searchTypes = ["grocery_or_supermarket"]
    private let searchRadius: Double = 1000

    public func findNearbyPlaces() {
        guard let coordinate = mapCentre?.coordinate else { return }

        delegate?.activityDidStart()
        GoogleMapsService.shared.getNearbyPlaces(coordinate: coordinate, radius: searchRadius, types: searchTypes)
            .then { places in
                self.delegate?.markPlaces(places)
            }.catch { error in
                self.delegate?.showErrorMessage(error.localizedDescription)
            }.always {
                self.delegate?.activityDidStop()
        }
    }
}
