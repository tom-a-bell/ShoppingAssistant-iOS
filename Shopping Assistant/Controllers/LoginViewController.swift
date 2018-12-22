import UIKit

class LoginViewController: BaseViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!

    private let viewModel = LoginViewModel()

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
}

// MARK: - LoginViewModelDelegate
extension LoginViewController: LoginViewModelDelegate {
    func didLogin() {
        updateButtonStates(isLoggedIn: true)
        dismiss(animated: true)
    }

    func didLogout() {
        updateButtonStates(isLoggedIn: false)
    }

    private func updateButtonStates(isLoggedIn: Bool) {
        loginButton.isHidden = isLoggedIn
        logoutButton.isHidden = !isLoggedIn

        loginButton.isEnabled = !isLoggedIn
        logoutButton.isEnabled = isLoggedIn
    }
}

// MARK: - ActivityIndicatable
extension LoginViewController: ActivityIndicatable {
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
    }
}

// MARK: - ErrorPresentable
extension LoginViewController: ErrorPresentable {}
