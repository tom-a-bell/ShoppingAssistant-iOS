import Foundation

protocol LocationsViewModelDelegate: MapViewModelDelegate {
    func markLocations(_ locations: [Location])
}

class LocationsViewModel: MapViewModel {

    private var locationsDelegate: LocationsViewModelDelegate?
    override var delegate: MapViewModelDelegate? {
        get { return locationsDelegate }
        set { locationsDelegate = newValue as? LocationsViewModelDelegate }
    }

    public override func onViewDidLoad() {
        super.onViewDidLoad()
    }

    public func onViewWillAppear() {
        fetchLocations()
    }

    private func fetchLocations() {
        delegate?.showLoadingSpinner()
        LocationsService.shared.fetchLocations()
            .then { locations in
                self.locationsDelegate?.markLocations(locations)
            }.catch { error in
                self.delegate?.showErrorMessage(error.localizedDescription)
            }.always {
                self.delegate?.hideLoadingSpinner()
        }
    }
}
