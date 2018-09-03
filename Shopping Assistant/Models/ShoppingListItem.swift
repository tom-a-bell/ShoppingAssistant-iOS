import Foundation

struct ShoppingListItem: Codable {
    var id: UUID?
    var name: String
    var status: Status
    var locationId: UUID?
    var location: Location?
    var createdTime: Date
    var updatedTime: Date
    var version: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name = "value"
        case version
        case status
        case locationId
        case createdTime
        case updatedTime
    }
}

extension ShoppingListItem {
    private static let dateFormat = "EEE MMM dd HH:mm:ss 'UTC' yyyy" // "Tue Jul 17 01:23:45 UTC 2018"

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter
    }()

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()

    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        return encoder
    }()

    static func newItem() -> ShoppingListItem {
        return ShoppingListItem(
            id: UUID(),
            name: "",
            status: .active,
            locationId: nil,
            location: nil,
            createdTime: Date(),
            updatedTime: Date(),
            version: 1
        )
    }
}

extension ShoppingListItem {
    var hasLocation: Bool {
        return locationId != nil
    }

    var isCompleted: Bool {
        return status == .completed
    }

    mutating func toggleStatus() {
        status = status == .active ? .completed : .active
    }
}

enum Status: String, Codable {
    case active, completed
}
