import Foundation

protocol AddLocationViewModelDelegate: MapViewModelDelegate {
    func didAddLocation()
}

class AddLocationViewModel: MapViewModel {

    private var addLocationDelegate: AddLocationViewModelDelegate?
    override var delegate: MapViewModelDelegate? {
        get { return addLocationDelegate }
        set { addLocationDelegate = newValue as? AddLocationViewModelDelegate }
    }

    public let location: Location

    init(with location: Location) {
        self.location = location
        super.init(centredAt: location.coordinate.asCLLocation())
    }

    override public func onViewDidLoad() {
        super.onViewDidLoad()
        delegate?.markPlaces([GooglePlace.from(location)])
    }

    public func addLocation() {
        delegate?.activityDidStart()
        LocationsService.shared.addLocation(location)
            .then { _ in
                self.addLocationDelegate?.didAddLocation()
            }.catch { error in
                self.delegate?.showErrorMessage(error.localizedDescription)
            }.always {
                self.delegate?.activityDidStop()
        }
    }
}
