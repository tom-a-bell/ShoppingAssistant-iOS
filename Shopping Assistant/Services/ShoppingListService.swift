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
                    let items = self.dataset.getAll().map { (key, value) in self.createItem(from: value, with: key) }
                    fulfill(items)
                }
                return nil
            }
        }
    }

    public func addItem(_ item: ShoppingListItem) -> Promise<Void> {
        guard let record = createRecord(from: item) else { return Promise.init(ParsingError()) }
        return Promise { fulfill, reject in
            self.dataset.setString(record, forKey: item.id?.uuidString)
            self.dataset.synchronize().continueWith { task in
                if let error = task.error {
                    reject(error)
                } else {
                    fulfill(())
                }
                return nil
            }
        }
    }

    private func createItem(from json: String, with id: String) -> ShoppingListItem {
        var item = createItem(from: json)
        item.id = UUID(uuidString: id)
        return item
    }

    private func createItem(from json: String) -> ShoppingListItem {
        return try! ShoppingListItem.decoder.decode(ShoppingListItem.self, from: json.data(using: .utf8)!)
    }

    private func createRecord(from item: ShoppingListItem) -> String? {
        let json = try! ShoppingListItem.encoder.encode(item)
        return String(data: json, encoding: .utf8)
    }
}
