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
        AmazonClientManager.shared.login() {_ in
            self.refreshUI()
        }
    }

    @IBAction func showLocations() {
        performSegue(withIdentifier: "ShowLocations", sender: self)
    }

    @IBAction func showShoppingList() {
        performSegue(withIdentifier: "ShowShoppingList", sender: self)
    }

    func disableUI() {
        loginButton.isEnabled = false
        locationsButton.isEnabled = false
        shoppingListButton.isEnabled = false
    }

    func refreshUI() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        updateButtonStates()
    }

    private func updateButtonStates() {
        let isLoggedIn = AmazonClientManager.shared.isLoggedIn()
        loginButton.isEnabled = !isLoggedIn
        locationsButton.isEnabled = isLoggedIn
        shoppingListButton.isEnabled = isLoggedIn
    }
}
