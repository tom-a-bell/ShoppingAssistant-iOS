import UIKit

class BaseNavigationController: UINavigationController, NavigationPresentable {

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        registerForNotifications()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        registerForNotifications()
    }

    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToShoppingList),
                                               name: .navigateToShoppingList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToLocations),
                                               name: .navigateToLocations, object: nil)
    }

    @objc
    func navigateToShoppingList(_ notification: Foundation.Notification) {
        navigateToViewController(withIdentifier: "ShoppingList")
    }

    @objc
    func navigateToLocations(_ notification: Foundation.Notification) {
        navigateToViewController(withIdentifier: "Locations")
    }

    private func navigateToViewController(withIdentifier identifier: String) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
        pushViewController(viewController, animated: true)
    }
}
