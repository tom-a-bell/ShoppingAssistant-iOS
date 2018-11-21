import Foundation

struct Location: Codable {
    let id: UUID
    let name: String
    let placeId: String
    let coordinate: Coordinate
    let radius: Double
}

extension Location {
    static func from(_ place: GooglePlace) -> Location {
        return Location(id: UUID(), name: place.name, placeId: place.id, coordinate: place.location, radius: 50)
    }
}

extension Location: Equatable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Location: Hashable {
    var hashValue: Int {
        return id.hashValue
    }
}
