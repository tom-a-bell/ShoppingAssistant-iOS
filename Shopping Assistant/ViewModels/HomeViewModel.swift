import Foundation

protocol HomeViewModelDelegate: AnyObject, ActivityIndicatable, ErrorPresentable {
    func showLoginModal()
}

class HomeViewModel {

    public weak var delegate: HomeViewModelDelegate?

    public func onViewDidLoad() {
        resumeSession()
    }

    public func resumeSession() {
        delegate?.activityDidStart()
        AmazonClientManager.shared.resumeSession()
            .always(updateActivityState)
            .catch(handleError)
    }

    private func updateActivityState() {
        delegate?.activityDidStop()
    }

    private func handleError(error: Error) {
        delegate?.showLoginModal()
    }
}
