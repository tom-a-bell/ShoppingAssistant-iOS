import Foundation

protocol AddShoppingListItemViewModelDelegate: ActivityIndicatable, ErrorPresentable {
    func didLoadLocations()
    func didSaveItem()
    func didCancelChanges()
}

class AddShoppingListItemViewModel {

    public var delegate: AddShoppingListItemViewModelDelegate?

    public var item: ShoppingListItem
    public var locations: [Location] = []

    public init(withItem item: ShoppingListItem) {
        self.item = item
    }

    public func onViewDidLoad() {
        fetchLocations()
    }

    public func setName(_ name: String) {
        item.name = name
    }

    public func setLocation(_ location: Location?) {
        item.locationId = location?.id
    }

    public func didSaveItem() {
        delegate?.activityDidStart()
        ShoppingListService.shared.addItem(item)
            .then { _ in
                self.delegate?.didSaveItem()
            }.catch { error in
                self.delegate?.showError(error)
            }.always {
                self.delegate?.activityDidStop()
        }
    }

    public func didCancelChanges() {
        delegate?.didCancelChanges()
    }

    private func fetchLocations() {
        delegate?.activityDidStart()
        LocationsService.shared.fetchLocations()
            .then { locations in
                self.locations = locations
                self.delegate?.didLoadLocations()
            }.catch { error in
                self.delegate?.showError(error)
            }.always {
                self.delegate?.activityDidStop()
        }
    }
}
