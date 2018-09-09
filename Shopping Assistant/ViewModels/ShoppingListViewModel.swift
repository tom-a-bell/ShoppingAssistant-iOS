import Foundation
import Promises

protocol ShoppingListViewModelDelegate: ActivityIndicatable, ErrorPresentable {
    func didLoadItems()
}

class ShoppingListViewModel {

    public var delegate: ShoppingListViewModelDelegate?

    public var items: [ShoppingListItem] = []
    public var selectedItem: ShoppingListItem?

    public func onViewDidLoad() {
    }

    public func onViewWillAppear() {
        fetchItems()
    }

    public func didSelectItem(_ item: ShoppingListItem) {
        selectedItem = item
    }

    public func didDeselectItem() {
        selectedItem = nil
    }

    public func didEndEditing() {
        print("Saving shopping list items...")
        delegate?.activityDidStart()
        ShoppingListService.shared.updateItems(items)
            .then {
                GeofenceService.shared.updateLocationMonitoring(for: self.items)
            }.catch { error in
                self.delegate?.showError(error)
            }.always {
                self.delegate?.activityDidStop()
        }
    }

    private func fetchItems() {
        delegate?.activityDidStart()
        ShoppingListService.shared.fetchItems()
            .then { items in
                self.populateItems(items)
            }.then { items in
                self.sortItems(items)
            }.then { items in
                self.items = items
                self.delegate?.didLoadItems()
            }.catch { error in
                self.delegate?.showError(error)
            }.always {
                self.delegate?.activityDidStop()
        }
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

    private func fetchLocationsById() -> Promise<[UUID:Location]> {
        return LocationsService.shared.fetchLocations().then { locations in
            locations.reduce(into: [:]) { result, location in
                result[location.id] = location
            }
        }
    }
}
