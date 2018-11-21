import Foundation
import AWSCore
import AWSCognito
import Promises

class LocationsService {

    static let shared = LocationsService()

    private let dataset = AWSCognito.default().openOrCreateDataset("Locations")

    public func fetchLocations() -> Promise<[Location]> {
        print("Fetching saved locations...")
        return Promise<[Location]> { fulfill, reject in
            self.dataset.synchronize().continueWith { task in
                if let error = task.error {
                    reject(error)
                } else {
                    let locations = self.dataset.getAll().map { (key, value) in self.createLocation(from: value) }
                    fulfill(locations)
                }
                return nil
            }
        }
    }

    public func fetchCachedLocations() -> Promise<[Location]> {
        print("Fetching cached locations...")
        let locations = self.dataset.getAll().map { (key, value) in self.createLocation(from: value) }
        return Promise(locations)
    }

    public func addLocation(_ location: Location) -> Promise<Void> {
        guard let record = createRecord(from: location) else { return Promise.init(ParsingError()) }
        return Promise { fulfill, reject in
            self.dataset.setString(record, forKey: location.id.stringValue)
            self.dataset.synchronize().continueWith { task in
                if let error = task.error {
                    reject(error)
                } else {
                    fulfill(())
                }
                return nil
            }
        }
    }

    private func createLocation(from json: String) -> Location {
        return try! JSONDecoder().decode(Location.self, from: json.data(using: .utf8)!)
    }

    private func createRecord(from location: Location) -> String? {
        let json = try! JSONEncoder().encode(location)
        return String(data: json, encoding: .utf8)
    }
}

struct ParsingError: LocalizedError {
    public var errorDescription: String? {
        return "Failed to convert Location to String"
    }
}
