import Foundation

protocol LoginViewModelDelegate: AnyObject, ActivityIndicatable, ErrorPresentable {
    func didLogin()
    func didLogout()
}

class LoginViewModel {

    public weak var delegate: LoginViewModelDelegate?

    public func onViewDidLoad() {
        updateLoginState()
    }

    public func performLogin() {
        delegate?.activityDidStart()
        AmazonClientManager.shared.login()
            .always(updateLoginState)
            .catch(handleError)
    }

    public func performLogout() {
        delegate?.activityDidStart()
        AmazonClientManager.shared.logout()
            .always(updateLoginState)
            .catch(handleError)
    }

    private func updateLoginState() {
        delegate?.activityDidStop()

        let isLoggedIn = AmazonClientManager.shared.isLoggedIn()
        isLoggedIn ? delegate?.didLogin() : delegate?.didLogout()
    }

    private func handleError(error: Error) {
        delegate?.showError(error)
    }
}
