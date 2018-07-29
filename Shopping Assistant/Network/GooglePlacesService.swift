import Foundation
import CoreLocation
import Moya

enum GooglePlacesService {
    case getNearbyPlaces(coordinate: CLLocationCoordinate2D, radius: Double, types: [String], apiKey: String)
}

// MARK: - TargetType Protocol Implementation
extension GooglePlacesService: TargetType {
    var baseURL: URL { return URL(string: "https://maps.googleapis.com/maps/api/place")! }

    var path: String {
        switch self {
        case .getNearbyPlaces:
            return "/nearbysearch/json"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getNearbyPlaces:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .getNearbyPlaces(coordinate, radius, types, apiKey):
            let parameters: [String : Any] = [
                "location": "\(coordinate.latitude),\(coordinate.longitude)",
                "types": types.joined(separator: "|"),
                "rankby": "prominence",
                "radius": radius,
                "sensor": true,
                "key": apiKey
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }

    var sampleData: Data {
        switch self {
        case .getNearbyPlaces:
            return """
                [
                    {
                        "geometry": {
                            "location": {
                                "lat": 51.5105224,
                                "lng": -0.1360772
                            },
                            "viewport": {
                                "northeast": {
                                    "lat": 51.5117886302915,
                                    "lng": -0.1340546
                                },
                                "southwest": {
                                    "lat": 51.5090906697085,
                                    "lng": -0.1374898
                                }
                            }
                        },
                        "icon": "https://maps.gstatic.com/mapfiles/place_api/icons/shopping-71.png",
                        "id": "d99c8883becbdb3db2c4bd0ae91390f165df1015",
                        "name": "Whole Foods Market",
                        "place_id": "ChIJpVeKbdQEdkgR__KpXSd4neU",
                        "types": [
                            "grocery_or_supermarket",
                            "supermarket",
                            "store",
                            "health",
                            "food",
                            "point_of_interest",
                            "establishment"
                        ],
                        "vicinity": "20 Glasshouse Street, London"
                    }
                ]
            """.utf8Encoded
        }
    }
}
