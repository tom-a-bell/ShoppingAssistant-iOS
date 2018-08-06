import Foundation

struct ShoppingListItem: Codable {
    var name: String
    var status: Status

    enum CodingKeys: String, CodingKey {
        case name = "value"
        case status
    }
}

enum Status: String, Codable {
    case active, completed
}
