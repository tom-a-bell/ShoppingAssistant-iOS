import Foundation
import AWSCore
import AWSCognito

protocol LocationsViewModelDelegate: MapViewModelDelegate {
    func locationsDidLoad()
    func showErrorMessage(_: String)
}

class LocationsViewModel: MapViewModel {

    private var locationsDelegate: LocationsViewModelDelegate?
    override var delegate: MapViewModelDelegate? {
        get { return locationsDelegate }
        set { locationsDelegate = newValue as? LocationsViewModelDelegate }
    }

    public var isLoading: Bool = false
    public var locations: [Location] = []

    private var dataset: AWSCognitoDataset?

    public override func onViewDidLoad() {
        super.onViewDidLoad()
        fetchLocations()
    }

    private func fetchLocations() {
        isLoading = true

        dataset = AWSCognito.default().openOrCreateDataset("Locations")
        dataset?.synchronize().continueWith { task in
            self.isLoading = false

            if let error = task.error {
                self.locationsDelegate?.showErrorMessage(error.localizedDescription)
            } else {
                self.locations = (self.dataset?.getAll().map { (key, value) in self.createLocation(from: value) })!
                self.locations.append(self.createTestLocation())
            }

            DispatchQueue.main.async() {
                self.locationsDelegate?.locationsDidLoad()
            }
            return nil
        }
    }

    private func createLocation(from json: String) -> Location {
        return try! JSONDecoder().decode(Location.self, from: json.data(using: .utf8)!)
    }

    private func createTestLocation() -> Location {
        return Location(
            id: UUID(),
            name: "Sainsburys",
            placeId: "",
            coordinate: Coordinate(latitude: 51.50998, longitude: -0.1337),
            radius: 100
        )
    }
}
