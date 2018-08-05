import UIKit

class LocationsViewController: MapViewController<LocationsViewModel> {

    override func viewDidLoad() {
        viewModel = LocationsViewModel()
        super.viewDidLoad()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? FindLocationViewController,
            let location = viewModel.mapCentre else { return }

        destination.viewModel = FindLocationViewModel(centredAt: location)
    }

    // MARK: - Actions

    @IBAction func addLocation() {
        performSegue(withIdentifier: "FindLocations", sender: self)
    }
}

// MARK: - LocationsViewModelDelegate
extension LocationsViewController: LocationsViewModelDelegate {
    func markLocations(_ locations: [Location]) {
        locations.forEach {
            let marker = LocationMarker(location: $0)
            marker.map = mapView
        }
    }
}
