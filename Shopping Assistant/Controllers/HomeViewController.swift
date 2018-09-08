import UIKit
import AWSCore

class HomeViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var locationsButton: UIButton!
    @IBOutlet weak var shoppingListButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateButtonStates()
    }

    @IBAction func performLogin() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        disableUI()
        AmazonClientManager.shared.login()
            .always(refreshUI)
            .catch(handleError)
        }
    }

    @IBAction func showLocations() {
        performSegue(withIdentifier: "ShowLocations", sender: self)
    }

    @IBAction func showShoppingList() {
        performSegue(withIdentifier: "ShowShoppingList", sender: self)
    }

    private func disableUI() {
        loginButton.isEnabled = false
        locationsButton.isEnabled = false
        shoppingListButton.isEnabled = false
    }

    private func refreshUI() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        updateButtonStates()
    }

    private func updateButtonStates() {
        let isLoggedIn = AmazonClientManager.shared.isLoggedIn()
        loginButton.isEnabled = !isLoggedIn
        locationsButton.isEnabled = isLoggedIn
        shoppingListButton.isEnabled = isLoggedIn
    }

    private func handleError(error: Error) {
        let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default)

        errorAlert.addAction(dismissAction)

        present(errorAlert, animated: true, completion: nil)
    }
}
