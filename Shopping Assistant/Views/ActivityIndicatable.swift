import UIKit

protocol ActivityIndicatable {
    var activityIndicator: UIActivityIndicatorView { get }
    func activityDidStart()
    func activityDidStop()
}

extension ActivityIndicatable {
    func activityDidStart() {
        activityIndicator.startAnimating()
    }

    func activityDidStop() {
        activityIndicator.stopAnimating()
    }
}
