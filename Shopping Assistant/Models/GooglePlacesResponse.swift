import Foundation

struct GooglePlacesResponse: Decodable {
    let results: [GooglePlace]
    let status: String
}
