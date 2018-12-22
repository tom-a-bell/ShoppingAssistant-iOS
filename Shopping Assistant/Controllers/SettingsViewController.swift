import UIKit

class SettingsViewController: BaseViewController {

    @IBOutlet weak var logoutButton: UIButton!

    private let viewModel = SettingsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        viewModel.onViewDidLoad()
    }
}

// MARK: - SettingsViewModelDelegate
extension SettingsViewController: SettingsViewModelDelegate {
}
