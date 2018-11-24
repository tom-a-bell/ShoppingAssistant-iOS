import Foundation

protocol HomeViewModelDelegate: AnyObject, ActivityIndicatable, ErrorPresentable {
    func didLogin()
    func didLogout()
}

class HomeViewModel {

    public weak var delegate: HomeViewModelDelegate?

    public func onViewDidLoad() {
        updateLoginState()
        resumeSession()
    }

    public func resumeSession() {
        delegate?.activityDidStart()
        AmazonClientManager.shared.resumeSession()
            .always(updateLoginState)
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
