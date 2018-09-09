import UIKit

class BaseViewController: UIViewController {
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center

        view.addSubview(activityIndicator)

        return activityIndicator
    }()
}
