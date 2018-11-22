import UIKit

protocol ErrorPresentable {
    func showError(_ error: Error)
}

extension ErrorPresentable where Self: UIViewController {
    func showError(_ error: Error) {
        Log.error("Error encountered:", error: error)

        let title = "Error"
        let message = error.localizedDescription
        let dismissAction = UIAlertAction(title: "OK", style: .default)

        let errorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        errorAlert.addAction(dismissAction)

        present(errorAlert, animated: true, completion: nil)
    }
}
