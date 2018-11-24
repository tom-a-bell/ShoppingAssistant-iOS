import Foundation
import CoreLocation
import UserNotifications
import Promises

class NotificationsManager: NSObject {

    static let shared = NotificationsManager()

    private let notificationCenter = UNUserNotificationCenter.current()

    private var authorizationPromise: Promise<Bool>?

    override init() {
        super.init()
        notificationCenter.delegate = self
    }

    func requestAuthorization() -> Promise<Bool> {
        if let authorizationPromise = authorizationPromise { return authorizationPromise }

        authorizationPromise = Promise<Bool>.pending()
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if let error = error {
                self.authorizationPromise?.reject(error)
            } else {
                self.authorizationPromise?.fulfill(granted)
            }
            if granted {
                self.setNotificationCategories()
            }
        }

        return authorizationPromise!
    }

    func showNotification(with title: String, body: String, afterTimeInterval timeInterval: TimeInterval = 0) {
        let trigger: UNNotificationTrigger?
        if timeInterval > 0 {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        } else {
            trigger = nil // Deliver the notification immediately.
        }

        let content = UNMutableNotificationContent()
        content.categoryIdentifier = NotificationCategory.singleItem
        content.title = title
        content.body = body

        let request = UNNotificationRequest(identifier: "Notification", content: content, trigger: trigger)
        addRequest(request)
    }

    func showNotification(for location: Location, with items: [ShoppingListItem]) {
        let request = Notification.createLocalNotification(for: location, with: items)
        addRequest(request)
    }

    func removeNotification(for location: Location) {
        let identifier = location.id.stringValue
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func removeAllNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
    }

    private func setNotificationCategories() {
        let actions = NotificationAction.allActions()
        let singleItem = UNNotificationCategory(identifier: NotificationCategory.singleItem, actions: actions, intentIdentifiers: [], options: [])
        let multipleItems = UNNotificationCategory(identifier: NotificationCategory.multipleItems, actions: actions, intentIdentifiers: [], options: [])

        notificationCenter.setNotificationCategories([singleItem, multipleItems])
    }

    private func addRequest(_ request: UNNotificationRequest) {
        notificationCenter.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Added notification for: \(request.content.title)")
            }
        }
    }
}

extension NotificationsManager: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            print("User opened the app from notification: \(response.notification.request.content.title)")
        case UNNotificationDismissActionIdentifier:
            print("User dismissed the notification: \(response.notification.request.content.title)")
        case NotificationAction.view.identifier:
            print("User requested more details for notification: \(response.notification.request.content.title)")
        case NotificationAction.complete.identifier:
            print("User completed the item(s) for notification: \(response.notification.request.content.title)")
            markAllItemsCompleted(for: response.notification)
        case NotificationAction.postpone.identifier:
            print("User postponed the notification: \(response.notification.request.content.title)")
        default:
            print("Unknown action (\(response.actionIdentifier)) for notification: \(response.notification.request.content.title)")
        }

        completionHandler()
    }

    private func markAllItemsCompleted(for notification: UNNotification) {
        let itemIds = getItemIds(from: notification)
        ShoppingListService.shared.markItemsCompleted(with: itemIds)
    }

    private func getItemIds(from notification: UNNotification) -> [UUID] {
        return notification.request.content.userInfo.values
            .compactMap { NotificationItem(from: $0) }
            .compactMap { UUID(uuidString: $0.id) }
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}
