import UIKit

class HomeViewController: UITabBarController {

    @IBInspectable var defaultIndex: Int = 1

    private let viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedIndex = defaultIndex

        viewModel.delegate = self
        viewModel.onViewDidLoad()
    }
}

// MARK: - HomeViewModelDelegate
extension HomeViewController: HomeViewModelDelegate {
    func showLoginModal() {
        performSegue(withIdentifier: "ShowLoginModal", sender: self)
    }
}

// MARK: - ActivityIndicatable
extension HomeViewController: ActivityIndicatable {
    var activityIndicator: UIActivityIndicatorView {
        if let selectedNavigationController = selectedViewController as? BaseNavigationController,
            let currentlyVisibleController = selectedNavigationController.visibleViewController as? BaseViewController {
            return currentlyVisibleController.activityIndicator
        }

        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        activityIndicator.style = .whiteLarge
        activityIndicator.color = .darkGray

        view.addSubview(activityIndicator)

        return activityIndicator
   }
}

// MARK: - ErrorPresentable
extension HomeViewController: ErrorPresentable {}
