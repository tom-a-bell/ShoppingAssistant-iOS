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
        NotificationsManager.shared.addNotication(for: location, with: items)
    }

    func stopMonitoring(_ location: Location) {
        NotificationsManager.shared.removeNotification(with: location.id.stringValue)
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
