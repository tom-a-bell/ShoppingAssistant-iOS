import Foundation
import AWSCore
import AWSCognito
import Promises

// swiftlint:disable unused_closure_parameter
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

    public func fetchCachedItems() -> Promise<[ShoppingListItem]> {
        print("Fetching cached shopping list items...")
        let items = self.dataset.getAll().map { (key, value) in self.createItem(from: value) }
        return Promise(items)
    }

    public func findItems(with ids: [UUID]) -> Promise<[ShoppingListItem]> {
        return fetchItems().then { items in
            return items.filter { ids.contains($0.id) }
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

    public func deleteItem(_ item: ShoppingListItem) -> Promise<Void> {
        return Promise { fulfill, reject in
            self.dataset.removeObject(forKey: item.id.stringValue)
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

    public func saveItems(_ items: [ShoppingListItem]) -> Promise<Void> {
        let records = createRecords(from: items)
        return Promise { fulfill, reject in
            records.forEach { (key, record) in
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

    private func createRecords(from items: [ShoppingListItem]) -> [String: String] {
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

    public func markItemsCompleted(with ids: [UUID]) {
        findItems(with: ids).then(markItemsCompleted).then(saveItems)
    }

    private func markItemsCompleted(_ items: [ShoppingListItem]) -> Promise<[ShoppingListItem]> {
        let completedItems = items.map { (item: ShoppingListItem) -> ShoppingListItem in
            var completedItem = item
            completedItem.markCompleted()
            return completedItem
        }
        return Promise(completedItems)
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
