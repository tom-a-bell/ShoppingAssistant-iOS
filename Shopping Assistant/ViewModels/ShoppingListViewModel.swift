import Foundation
import AWSCore
import AWSCognito

protocol ShoppingListViewModelDelegate {
    func itemsDidLoad()
    func showErrorMessage(_: String)
}

class ShoppingListViewModel {

    public var delegate: ShoppingListViewModelDelegate?

    public var isLoading = false
    public var items: [ShoppingListItem] = []

    public func onViewDidLoad() {
        fetchItems()
    }




    private func fetchItems() {
        isLoading = true
        ShoppingListService.shared.fetchItems()
            .then { items in
                self.items = items
                self.delegate?.itemsDidLoad()
            }.catch { error in
                self.delegate?.showErrorMessage(error.localizedDescription)
            }.always {
                self.isLoading = false
        }
    }
}
