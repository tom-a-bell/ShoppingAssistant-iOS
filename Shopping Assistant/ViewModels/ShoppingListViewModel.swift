import Foundation
import Promises

protocol ShoppingListViewModelDelegate: AnyObject, ActivityIndicatable, ErrorPresentable {
    func didLoadItems()
}

class ShoppingListViewModel {

    public weak var delegate: ShoppingListViewModelDelegate?

    public var selectedItem: ShoppingListItem?
    public var selectedLocationId: UUID?

    private var allItems: [ShoppingListItem] = []

    public var items: [ShoppingListItem] {
        return selectedLocationId == nil ? allItems : allItems.filter { $0.locationId == selectedLocationId }
    }

    public func onViewDidLoad() {}

    public func onViewWillAppear() {
        selectedLocationId = NavigationService.shared.getShoppingListLocationId()
        NavigationService.shared.didNavigateToShoppingList()
        selectedItem = nil
        fetchItems()
    }

    public func onViewWillDisappear() {
        guard selectedItem == nil else { return }
        selectedLocationId = nil
        didEndEditing()
    }

    public func didSelect(_ item: ShoppingListItem) {
        selectedItem = item
    }

    public func didDeselectItem() {
        selectedItem = nil
    }

    public func didUpdate(_ item: ShoppingListItem) {
        guard let index = allItems.firstIndex(of: item) else { return }
        FileService.shared.recordUpdatedItem(item)
        allItems[index] = item
    }

    public func didRemove(_ item: ShoppingListItem) {
        allItems.removeFirst(item)
        FileService.shared.recordDeletedItem(item)
        ShoppingListService.shared.deleteItem(item)
            .catch(handleError)
    }

    public func didMove(_ item: ShoppingListItem, to index: Int) {
        guard let index = allItems.firstIndex(of: items[index]) else { return }
        allItems.removeFirst(item)
        allItems.insert(item, at: index)
    }

    public func didEndEditing() {
        Log.info("Saving shopping list items...")
        updateItems()
    }

    private func fetchItems() {
        delegate?.activityDidStart()
        ShoppingListService.shared.fetchItems()
            .then(populateItems)
            .then(sortItems)
            .then(displayItems)
            .catch(handleError)
            .always(stopActivity)
    }

    private func updateItems() {
        delegate?.activityDidStart()
        ShoppingListService.shared.updateItems(allItems)
            .then(updateLocationMonitoring)
            .catch(handleError)
            .always(stopActivity)
    }

    private func populateItems(_ items: [ShoppingListItem]) -> Promise<[ShoppingListItem]> {
        return fetchLocationsById().then { locations in
            items.map { item in
                guard let id = item.locationId else { return item }
                var item = item
                item.location = locations[id]
                return item
            }
        }
    }

    private func sortItems(_ items: [ShoppingListItem]) -> Promise<[ShoppingListItem]> {
        let completedThenByLastUpdated: (ShoppingListItem, ShoppingListItem) -> (Bool) = {
            return $0.isCompleted == $1.isCompleted ? $0.updatedTime > $1.updatedTime : $1.isCompleted
        }
        let sortedItems = items.sorted(by: completedThenByLastUpdated)
        return Promise(sortedItems)
    }

    private func displayItems(_ items: [ShoppingListItem]) {
        self.allItems = items
        delegate?.didLoadItems()
    }

    private func fetchLocationsById() -> Promise<[UUID: Location]> {
        return LocationsService.shared.fetchLocations().then { locations in
            locations.reduce(into: [:]) { result, location in
                result[location.id] = location
            }
        }
    }

    private func updateLocationMonitoring() -> Promise<Void> {
        return GeofenceService.shared.updateLocationMonitoring(for: allItems)
    }

    private func handleError(error: Error) {
        delegate?.showError(error)
    }

    private func stopActivity() {
        delegate?.activityDidStop()
    }
}
