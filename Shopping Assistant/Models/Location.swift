import Foundation

struct Location: Decodable {
    let id: UUID
    let name: String
    let placeId: String
    let coordinate: Coordinate
    let radius: Double
}
