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
        content.categoryIdentifier = NotificationCategory.multipleItems
        content.title = title
        content.body = body

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        content.userInfo = [
            "1": ["id": "1", "name": "Test Item 1", "lastUpdated": dateFormatter.date(from: "2018-09-06 10:21:37")!],
            "2": ["id": "2", "name": "Test Item 2", "lastUpdated": dateFormatter.date(from: "2018-09-01 10:21:37")!],
            "3": ["id": "3", "name": "Test Item 3", "lastUpdated": dateFormatter.date(from: "2018-08-27 13:18:37")!],
            "4": ["id": "4", "name": "Test Item 4", "lastUpdated": dateFormatter.date(from: "2018-08-15 10:21:37")!]
        ]

        let request = UNNotificationRequest(identifier: "Notification", content: content, trigger: trigger)
        addRequest(request)
    }

    func addNotication(for location: Location, with items: [ShoppingListItem]) {
        let request = Notification.createNotification(for: location, with: items)
        addRequest(request)
    }

    func removeNotification(with identifier: String) {
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
        case NotificationAction.postpone.identifier:
            print("User postponed the notification: \(response.notification.request.content.title)")
        default:
            print("Unknown action (\(response.actionIdentifier)) for notification: \(response.notification.request.content.title)")
        }

        completionHandler()
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}
