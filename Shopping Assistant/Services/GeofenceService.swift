import Foundation
import Promises

class GeofenceService {

    static let shared = GeofenceService()

    func updateLocationMonitoring(for items:[ShoppingListItem]) -> Promise<Void> {
        let itemsWithLocations = items.filter { $0.hasLocation && !$0.isCompleted }
        let locationsWithItems = Dictionary(grouping: itemsWithLocations, by: { $0.location! })
        let updateMonitoringForLocations = { locations in self.updateMonitoring(for: locations, locationsToMonitor: locationsWithItems) }
        return LocationsService.shared.fetchLocations().then(updateMonitoringForLocations)
    }

    private func updateMonitoring(for locations: [Location], locationsToMonitor: [Location : [ShoppingListItem]]) {
        locations.forEach { location in
            if let items = locationsToMonitor[location] {
                self.startMonitoring(location, with: items)
            } else {
                self.stopMonitoring(location)
            }
        }
    }

    func startMonitoring(_ location: Location, with items: [ShoppingListItem]) {
        let region = LocationManager.shared.region(for: location)
        let message = notificationMessage(for: items)
        let title = notificationTitle(for: location)

        NotificationsManager.shared.addNotication(for: region, with: title, body: message)
    }

    func stopMonitoring(_ location: Location) {
        NotificationsManager.shared.removeNotification(with: location.id.stringValue)
    }

    private func notificationTitle(for location: Location) -> String {
        return location.name
    }

    private func notificationMessage(for items: [ShoppingListItem]) -> String {
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

extension Location: Hashable {
    var hashValue: Int {
        return id.hashValue
    }
}

extension Location: Equatable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id
    }
}
