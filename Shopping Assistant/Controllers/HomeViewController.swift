import UIKit

class HomeViewController: BaseViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var locationsButton: UIButton!
    @IBOutlet weak var shoppingListButton: UIButton!

    private let viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        viewModel.onViewDidLoad()
    }

    // MARK: - Actions

    @IBAction func performLogin() {
        viewModel.performLogin()
    }

    @IBAction func performLogout() {
        viewModel.performLogout()
    }

    @IBAction func showLocations() {
        performSegue(withIdentifier: "ShowLocations", sender: self)
    }

    @IBAction func showShoppingList() {
        performSegue(withIdentifier: "ShowShoppingList", sender: self)
    }
}

// MARK: - HomeViewModelDelegate
extension HomeViewController: HomeViewModelDelegate {
    func didLogin() {
        updateButtonStates(isLoggedIn: true)
    }

    func didLogout() {
        updateButtonStates(isLoggedIn: false)
    }

    private func updateButtonStates(isLoggedIn: Bool) {
        loginButton.isHidden = isLoggedIn
        logoutButton.isHidden = !isLoggedIn

        loginButton.isEnabled = !isLoggedIn
        logoutButton.isEnabled = isLoggedIn
        locationsButton.isEnabled = isLoggedIn
        shoppingListButton.isEnabled = isLoggedIn
    }
}

// MARK: - ActivityIndicatable
extension HomeViewController: ActivityIndicatable {
    func activityDidStart() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
        disableButtons()
    }

    func activityDidStop() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        activityIndicator.stopAnimating()
    }

    private func disableButtons() {
        loginButton.isEnabled = false
        logoutButton.isEnabled = false
        locationsButton.isEnabled = false
        shoppingListButton.isEnabled = false
    }
}

// MARK: - ErrorPresentable
extension HomeViewController: ErrorPresentable {}
