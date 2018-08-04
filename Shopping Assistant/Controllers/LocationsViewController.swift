import UIKit

class LocationsViewController: MapViewController {

    private let viewModel = LocationsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        viewModel.onViewDidLoad()
    }
}

// MARK: - LocationsViewModelDelegate
extension LocationsViewController: LocationsViewModelDelegate {
    func locationsDidLoad() {
        viewModel.locations.forEach {
            let marker = LocationMarker(location: $0)
            marker.map = mapView
        }
    }

    func showErrorMessage(_ message: String) {
        let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default)

        errorAlert.addAction(dismissAction)

        self.present(errorAlert, animated: true, completion: nil)
    }
}
