import Foundation
import CoreLocation

struct Coordinate: Decodable {
    let latitude: Double
    let longitude: Double

    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
}

struct GooglePlace {
    let name: String
    let address: String
    let location: Coordinate
    let placeTypes: [String]
}

extension GooglePlace: Decodable {

    enum CodingKeys: String, CodingKey {
        case name
        case address = "vicinity"
        case placeTypes = "types"
        case geometry
    }

    enum GeometryKeys: String, CodingKey {
        case location
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        address = try values.decode(String.self, forKey: .address)
        placeTypes = try values.decode([String].self, forKey: .placeTypes)

        let geometry = try values.nestedContainer(keyedBy: GeometryKeys.self, forKey: .geometry)
        location = try geometry.decode(Coordinate.self, forKey: .location)
    }
}
