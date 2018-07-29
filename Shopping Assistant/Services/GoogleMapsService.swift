import Foundation
import GoogleMaps

class GoogleMapsService {

    static let shared = GoogleMapsService()

    func initialize() {
        GMSServices.provideAPIKey(GoogleConfiguration.apiKey)
    }
}
