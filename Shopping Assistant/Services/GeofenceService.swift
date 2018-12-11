import Foundation
import Promises

class GeofenceService {

    static let shared = GeofenceService()

    func updateLocationMonitoring(for items: [ShoppingListItem]) -> Promise<Void> {
        let locationsWithItems = items.compactMap { $0.location }.removingDuplicates()
        let updateMonitoringForLocations = { locations in self.updateMonitoring(for: locations, locationsToMonitor: locationsWithItems) }
        return LocationsService.shared.fetchLocations().then(updateMonitoringForLocations)
    }

    private func updateMonitoring(for locations: [Location], locationsToMonitor: [Location]) {
        locations.forEach { location in
            if locationsToMonitor.contains(location) {
                LocationManager.shared.startMonitoring(location)
            } else {
                LocationManager.shared.stopMonitoring(location)
            }
        }
    }

    func didEnter(_ location: Location) {
        Log.info("Entering location with ID: \(location.id)")
        guard isWithinNotificationTimePeriod else { return }

        getDetailsAndItems(for: location)
            .then(displayNotification)
            .catch(handleError)
    }

    func didExit(_ location: Location) {
        Log.info("Exiting location with ID: \(location.id)")
        NotificationsManager.shared.removeNotification(for: location)
    }

    private func getDetailsAndItems(for location: Location) -> Promise<(Location?, [ShoppingListItem])> {
        return Promises.all(getDetails(for: location), getActiveItems(for: location))
    }

    private func getDetails(for location: Location) -> Promise<Location?> {
        return LocationsService.shared.fetchCachedLocations().then { locations in
            locations.first(where: {$0.id == location.id })
        }
    }

    private func getActiveItems(for location: Location) -> Promise<[ShoppingListItem]> {
        return ShoppingListService.shared.fetchCachedItems().then { items in
            items.filter { $0.locationId == location.id && !$0.isCompleted }
        }
    }

    private func displayNotification(for location: Location?, with items: [ShoppingListItem]) {
        guard !items.isEmpty, let location = location else { return }
        NotificationsManager.shared.showNotification(for: location, with: items)
    }

    private func handleError(error: Error) {
        Log.error("Error fetching notification content: \(error.localizedDescription)", error: error)
    }

    private var isWithinNotificationTimePeriod: Bool {
        let calendar = Calendar.current
        let now = Date()
        let todayAt2pm = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!
        let todayAt8pm = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: now)!

        return now >= todayAt2pm
            && now <= todayAt8pm
    }
}
