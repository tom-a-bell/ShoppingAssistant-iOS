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

    public func addItem(_ item: ShoppingListItem) -> Promise<Void> {
        guard let record = createRecord(from: item) else { return Promise.init(ParsingError()) }
        return Promise { fulfill, reject in
            self.dataset.setString(record, forKey: item.id.stringValue)
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

    }

    public func updateItems(_ items: [ShoppingListItem]) -> Promise<Void> {
        guard let oldRecords = dataset.getAll() else { return Promise.init(ParsingError()) }
        let newRecords = createRecords(from: items)

        let recordsToRemove = oldRecords.subtracting(newRecords)
        let recordsToUpdate = newRecords.subtracting(oldRecords)

        return Promise { fulfill, reject in
            recordsToRemove.forEach { (key, record) in
                self.dataset.removeObject(forKey: key)
            }

            recordsToUpdate.forEach { (key, record) in
                self.dataset.setString(record, forKey: key)
            }

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

    private func createItem(from json: String) -> ShoppingListItem {
        return try! ShoppingListItem.decoder.decode(ShoppingListItem.self, from: json.data(using: .utf8)!)
    }

    private func createRecords(from items: [ShoppingListItem]) -> [String : String] {
        return items.reduce(into: [:]) { result, item in
            let key = item.id.stringValue
            if let record = self.createRecord(from: item) {
                result[key] = record
            }
        }
    }

    private func createRecord(from item: ShoppingListItem) -> String? {
        let json = try! ShoppingListItem.encoder.encode(item)
        return String(data: json, encoding: .utf8)
    }
}

extension Dictionary where Key: Comparable, Value: Equatable {
    func subtracting(_ other: [Key: Value]) -> [Key: Value] {
        return reduce(into: [:]) { result, element in
            let (key, value) = element
            if (other[key] != value) {
                result[key] = value
            }
        }
    }
}
