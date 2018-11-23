import UIKit

class BaseViewController: UIViewController {
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        activityIndicator.style = .whiteLarge
        activityIndicator.color = .darkGray

        view.addSubview(activityIndicator)

        return activityIndicator
    }()
}
