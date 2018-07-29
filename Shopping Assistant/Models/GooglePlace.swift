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
    let id: String
    let name: String
    let address: String
    let location: Coordinate
    let placeTypes: [String]
    let iconUrl: URL
}

extension GooglePlace: Decodable {

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address = "vicinity"
        case placeTypes = "types"
        case iconUrl = "icon"
        case geometry
    }

    enum GeometryKeys: String, CodingKey {
        case location
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        address = try values.decode(String.self, forKey: .address)
        placeTypes = try values.decode([String].self, forKey: .placeTypes)
        iconUrl = try values.decode(URL.self, forKey: .iconUrl)

        let geometry = try values.nestedContainer(keyedBy: GeometryKeys.self, forKey: .geometry)
        location = try geometry.decode(Coordinate.self, forKey: .location)
    }
}
