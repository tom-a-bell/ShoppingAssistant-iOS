import UIKit

class FindLocationViewController: MapViewController<FindLocationViewModel> {

    @IBOutlet weak var searchButton: UIBarButtonItem!

    @IBAction func searchNearby() {
        viewModel.findNearbyPlaces()
    }
}
