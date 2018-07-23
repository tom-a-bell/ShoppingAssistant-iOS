import UIKit
import AWSCore

class HomeViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var shoppingListButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func performLogin() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        disableUI()
        AmazonClientManager.shared.login() {_ in
            self.refreshUI()
        }
    }

    @IBAction func showShoppingList() {
        performSegue(withIdentifier: "ShowShoppingList", sender: self)
    }

    func disableUI() {
        loginButton.isEnabled = false
        shoppingListButton.isEnabled = false
    }

    func refreshUI() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        let isLoggedIn = AmazonClientManager.shared.isLoggedIn()
        loginButton.isEnabled = !isLoggedIn
        shoppingListButton.isEnabled = isLoggedIn
    }
}
