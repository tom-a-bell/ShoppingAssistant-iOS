import Foundation

struct ShoppingListItem: Codable {
    var name: String
    var status: Status

    enum CodingKeys: String, CodingKey {
        case name = "value"
        case status
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
