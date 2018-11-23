import Foundation
import UserNotifications

struct Notification {

    static func createLocalNotification(for location: Location, with items: [ShoppingListItem]) -> UNNotificationRequest {
        return notificationRequest(for: location, with: items, trigger: nil) // Deliver the notification immediately.
    }

    static func createRegionNotification(for location: Location, with items: [ShoppingListItem]) -> UNNotificationRequest {
        let trigger = notificationTrigger(for: location)
        return notificationRequest(for: location, with: items, trigger: trigger)
    }

    private static func notificationRequest(for location: Location, with items: [ShoppingListItem],
                                            trigger: UNNotificationTrigger?) -> UNNotificationRequest {
        let identifier = notificationIdentifier(for: location)
        let content = notificationContent(for: location, with: items)

        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }

    private static func notificationIdentifier(for location: Location) -> String {
        return location.id.stringValue
    }

    private static func notificationTrigger(for location: Location) -> UNLocationNotificationTrigger {
        // Deliver the notification when entering the region associated with the location.
        let region = LocationManager.shared.region(for: location)
        return UNLocationNotificationTrigger(region: region, repeats: true)
    }

    private static func notificationContent(for location: Location, with items: [ShoppingListItem]) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = category(for: items)
        content.userInfo = userInfo(for: items)
        content.title = title(for: location)
        content.body = body(for: items)
        return content
    }

    private static func category(for items: [ShoppingListItem]) -> String {
        return items.count > 1 ? NotificationCategory.multipleItems : NotificationCategory.singleItem
    }

    private static func userInfo(for items: [ShoppingListItem]) -> [String: [String: Any]] {
        return Dictionary(uniqueKeysWithValues: items.map { ($0.key, $0.value) })
    }

    private static func title(for location: Location) -> String {
        return location.name
    }

    private static func body(for items: [ShoppingListItem]) -> String {
        guard let firstItem = items.first else { return "You have items on your shopping list to pick up here." }

        let firstItemName = firstItem.name.sentenceCased()
        let itemDescription: String
        switch items.count {
        case 1:
            itemDescription = firstItemName
        case 2:
            itemDescription = firstItemName + " and 1 other item"
        default:
            itemDescription = firstItemName + " and \(items.count - 1) other items"
        }

        return "\(itemDescription) to pick up here."
    }
}

enum NotificationCategory {
    static let singleItem = "singleItem"
    static let multipleItems = "multipleItems"
}

enum NotificationAction: String {
    case view
    case complete
    case postpone

    static var allCases: [NotificationAction] {
        return [.view, .complete, .postpone]
    }
}

extension NotificationAction {
    var identifier: String {
        return rawValue
    }

    var title: String {
        switch self {
        case .view:
            return "View Details"
        case .complete:
            return "Mark Completed"
        case .postpone:
            return "Remind Me Later"
        }
    }

    var action: UNNotificationAction {
        switch self {
        case .view:
            return UNNotificationAction(identifier: identifier, title: title, options: [.foreground])
        case .complete:
            return UNNotificationAction(identifier: identifier, title: title, options: [])
        case .postpone:
            return UNNotificationAction(identifier: identifier, title: title, options: [])
        }
    }

    static func allActions() -> [UNNotificationAction] {
        return allCases.map { $0.action }
    }
}

private extension ShoppingListItem {
    var key: String {
        return id.stringValue
    }

    var value: [String: Any] {
        return ["id": id.stringValue, "name": name, "lastUpdated": updatedTime]
    }
}
