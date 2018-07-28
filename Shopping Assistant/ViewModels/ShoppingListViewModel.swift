import Foundation
import AWSCore
import AWSCognito

protocol ShoppingListViewModelDelegate {
    func itemsDidLoad()
    func showErrorMessage(_: String)
}

class ShoppingListViewModel {

    public var delegate: ShoppingListViewModelDelegate?

    public var isLoading: Bool = false
    public var items: [ShoppingListItem?] = []

    private var shoppingList: AWSCognitoDataset?

    public func onViewDidLoad() {
        fetchItems()
    }

    private func fetchItems() {
        isLoading = true

        shoppingList = AWSCognito.default().openOrCreateDataset("ShoppingList")
        shoppingList?.synchronize().continueWith { task in
            self.isLoading = false

            if let error = task.error {
                self.delegate?.showErrorMessage(error.localizedDescription)
            } else {
                self.items = (self.shoppingList?.getAll().map { (key, value) in self.createItem(from: value) })!
            }

            DispatchQueue.main.async() {
                self.delegate?.itemsDidLoad()
            }
            return nil
        }
    }

    private func createItem(from json: String) -> ShoppingListItem? {
        return try? JSONDecoder().decode(ShoppingListItem.self, from: json.data(using: .utf8)!)
    }
}
