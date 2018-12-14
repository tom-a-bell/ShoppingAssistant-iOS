import Foundation

class FileService {

    static let shared = FileService()

    private let filename = "data.json"

    func recordCreatedItem(_ item: ShoppingListItem) {
        do {
            try writeRecord(for: item, withChange: .create)
        } catch {
            Log.error("Failed to record created item: \(error.localizedDescription)", error: error)
        }
    }

    func recordUpdatedItem(_ item: ShoppingListItem) {
        do {
            try writeRecord(for: item, withChange: .update)
        } catch {
            Log.error("Failed to record updated item: \(error.localizedDescription)", error: error)
        }
    }

    func recordDeletedItem(_ item: ShoppingListItem) {
        do {
            try writeRecord(for: item, withChange: .delete)
        } catch {
            Log.error("Failed to record deleted item: \(error.localizedDescription)", error: error)
        }
    }

    private func writeRecord(for item: ShoppingListItem, withChange change: Change) throws {
        let record = createRecord(for: item, withChange: change)
        try writeToFile(record)
    }

    private func createRecord(for item: ShoppingListItem, withChange change: Change) -> ItemRecord {
        let currentLocation = LocationManager.shared.currentLocation?.id.stringValue
        return ItemRecord(
            itemName: item.name,
            locationName: item.location?.name,
            currentLocation: currentLocation,
            createdTime: item.createdTime,
            updatedTime: Date(),
            status: item.status,
            change: change
        )
    }

    private func writeToFile(_ record: ItemRecord) throws {
        guard let file = documentsDirectory?.appendingPathComponent(filename) else { return }
        guard let json = try createJsonFor(record) else { return }

        let entry = json.appending(",\n")
        try entry.append(to: file, encoding: .utf8)
    }

    private func createJsonFor(_ record: ItemRecord) throws -> String? {
        let json = try encoder.encode(record)
        return String(data: json, encoding: .utf8)
    }

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        return encoder
    }

    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }

    private var documentsDirectory: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}

private struct ItemRecord: Codable {
    var itemName: String
    var locationName: String?
    var currentLocation: String?
    var createdTime: Date
    var updatedTime: Date
    var status: Status
    var change: Change
}

private enum Change: String, Codable {
    case create, update, delete
}

private extension String {
    func appendLine(to url: URL, encoding: Encoding) throws {
        try self.appending("\n").append(to: url, encoding: encoding)
    }

    func append(to url: URL, encoding: Encoding) throws {
        let data = self.data(using: encoding)
        try data?.append(to: url)
    }
}

private extension Data {
    func append(to url: URL) throws {
        if let fileHandle = try? FileHandle(forWritingTo: url) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        } else {
            try write(to: url)
        }
    }
}
