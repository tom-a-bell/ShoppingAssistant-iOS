import Foundation
import Promises

protocol ShoppingListViewModelDelegate {
    func didLoadItems()
    func showErrorMessage(_: String)
}

class ShoppingListViewModel {

    public var delegate: ShoppingListViewModelDelegate?

    public var isLoading = false
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
        isLoading = true
        ShoppingListService.shared.updateItems(items)
            .catch { error in
                self.delegate?.showErrorMessage(error.localizedDescription)
            }.always {
                self.isLoading = false
        }
    }

    private func fetchItems() {
        isLoading = true
        ShoppingListService.shared.fetchItems()
            .then { items in
                self.populateItems(items)
            }.then { items in
                self.items = items
                self.delegate?.didLoadItems()
            }.catch { error in
                self.delegate?.showErrorMessage(error.localizedDescription)
            }.always {
                self.isLoading = false
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

    private func fetchLocationsById() -> Promise<[UUID:Location]> {
        return LocationsService.shared.fetchLocations().then { locations in
            locations.reduce(into: [:]) { result, location in
                result[location.id] = location
            }
        }
    }
}
