import Foundation
import AWSCore
import AWSCognito
import Promises

class ShoppingListService {

    static let shared = ShoppingListService()

    private let dataset = AWSCognito.default().openOrCreateDataset("ShoppingList")

    public func fetchItems() -> Promise<[ShoppingListItem]> {
        print("Fetching shopping list items...")
        return Promise<[ShoppingListItem]> { fulfill, reject in
            self.dataset.synchronize().continueWith { task in
                if let error = task.error {
                    reject(error)
                } else {
                    let items = self.dataset.getAll().map { (key, value) in self.createItem(from: value) }
                    fulfill(items)
                }
                return nil
            }
        }
    }

    private func createItem(from json: String) -> ShoppingListItem {
        return try! JSONDecoder().decode(ShoppingListItem.self, from: json.data(using: .utf8)!)
    }
}
