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
        notificationCenter.requestAuthorization(options: [.alert]) { (granted, error) in
            if let error = error {
                self.authorizationPromise?.reject(error)
            } else {
                self.authorizationPromise?.fulfill(granted)
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

        let content = notificationContent(for: title, body: body)
        let request = UNNotificationRequest(identifier: "Notification", content: content, trigger: trigger)

        addRequest(request)
    }

    func addNotication(for region: CLRegion, with title: String, body: String) {
        // Deliver the notification when entering or exiting the region.
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)

        let content = notificationContent(for: title, body: body)
        let request = UNNotificationRequest(identifier: region.identifier, content: content, trigger: trigger)

        addRequest(request)
    }

    func removeNotification(with identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    private func notificationContent(for title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        return content
    }

    private func addRequest(_ request: UNNotificationRequest) {
        notificationCenter.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Added notification: \(request.content.title)")
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
