import UIKit

class AddLocationViewController: MapViewController<AddLocationViewModel> {

    @IBOutlet weak var addLocationButton: UIBarButtonItem!

    @IBAction func addLocation() {
        viewModel.addLocation()
    }
}

// MARK: - AddLocationViewModelDelegate
extension AddLocationViewController: AddLocationViewModelDelegate {
    func didAddLocation() {
        navigationController?.popViewController(animated: true)
    }
}
