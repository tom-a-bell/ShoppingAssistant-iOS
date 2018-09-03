import Foundation

protocol AddShoppingListItemViewModelDelegate {
    func didLoadLocations()
    func didSaveItem()
    func didCancelChanges()

    func showErrorMessage(_: String)
}

class AddShoppingListItemViewModel {

    public var delegate: AddShoppingListItemViewModelDelegate?

    public var isLoading = false
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
        isLoading = true
        ShoppingListService.shared.addItem(item)
            .then { _ in
                self.delegate?.didSaveItem()
            }.catch { error in
                self.delegate?.showErrorMessage(error.localizedDescription)
            }.always {
                self.isLoading = false
        }
    }

    public func didCancelChanges() {
        delegate?.didCancelChanges()
    }

    private func fetchLocations() {
        isLoading = true
        LocationsService.shared.fetchLocations()
            .then { locations in
                self.locations = locations
                self.delegate?.didLoadLocations()
            }.catch { error in
                self.delegate?.showErrorMessage(error.localizedDescription)
            }.always {
                self.isLoading = false
        }
    }
}
