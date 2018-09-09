import UIKit
import AWSCore

class HomeViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var locationsButton: UIButton!
    @IBOutlet weak var shoppingListButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateButtonStates()
        AmazonClientManager.shared.resumeSession().always(refreshUI)
    }

    @IBAction func performLogin() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        disableUI()
        AmazonClientManager.shared.login()
            .always(refreshUI)
            .catch(showError)
    }

    @IBAction func performLogout() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        disableUI()
        AmazonClientManager.shared.logout()
            .always(refreshUI)
            .catch(showError)
    }

    @IBAction func showLocations() {
        performSegue(withIdentifier: "ShowLocations", sender: self)
    }

    @IBAction func showShoppingList() {
        performSegue(withIdentifier: "ShowShoppingList", sender: self)
    }

    private func disableUI() {
        loginButton.isEnabled = false
        logoutButton.isEnabled = false
        locationsButton.isEnabled = false
        shoppingListButton.isEnabled = false
    }

    private func refreshUI() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        updateButtonStates()
    }

    private func updateButtonStates() {
        let isLoggedIn = AmazonClientManager.shared.isLoggedIn()

        loginButton.isHidden = isLoggedIn
        logoutButton.isHidden = !isLoggedIn

        loginButton.isEnabled = !isLoggedIn
        logoutButton.isEnabled = isLoggedIn
        locationsButton.isEnabled = isLoggedIn
        shoppingListButton.isEnabled = isLoggedIn
    }
}

// MARK: - ErrorPresentable
extension HomeViewController: ErrorPresentable {}
