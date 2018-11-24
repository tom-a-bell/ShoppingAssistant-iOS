import Foundation

class NavigationService {

    static let shared = NavigationService()

    private let notificationCenter: NotificationCenter

    private init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
    }

    private var navigateToShoppingListRequested = false
    private var navigateToLocationsRequested = false
    private var selectedLocationId: String?

    public func navigateToShoppingList(withLocationId locationId: String? = nil) {
        navigateToShoppingListRequested = true
        selectedLocationId = locationId

        notificationCenter.post(name: .navigateToShoppingList, object: selectedLocationId)
    }

    public func navigateToLocations() {
        navigateToLocationsRequested = true

        notificationCenter.post(name: .navigateToLocations, object: nil)
    }

    public func shouldNavigateToShoppingList() -> Bool {
        return navigateToShoppingListRequested
    }

    public func shouldNavigateToLocations() -> Bool {
        return navigateToLocationsRequested
    }

    public func getShoppingListLocationId() -> String? {
        return selectedLocationId
    }

    public func didNavigateToShoppingList() {
        navigateToShoppingListRequested = false
        selectedLocationId = nil
    }

    public func didNavigateToLocations() {
        navigateToLocationsRequested = false
    }
}

extension Foundation.Notification.Name {
    static var navigateToShoppingList: Foundation.Notification.Name {
        return .init(rawValue: "NavigationService.navigateToShoppingList")
    }

    static var navigateToLocations: Foundation.Notification.Name {
        return .init(rawValue: "NavigationService.navigateToLocations")
    }
}
