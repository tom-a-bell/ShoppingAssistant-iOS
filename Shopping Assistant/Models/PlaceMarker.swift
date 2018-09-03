import UIKit
import GoogleMaps

class PlaceMarker: GMSMarker {
    let place: GooglePlace

    init(place: GooglePlace) {
        self.place = place
        super.init()

        position = place.location.coordinate
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = .pop
    }

    convenience init(withId id: String, name: String, location: CLLocationCoordinate2D) {
        let place = GooglePlace(id: id, name: name, address: "", location: Coordinate.from(location), placeTypes: [], iconUrl: nil)
        self.init(place: place)
    }
}

extension CLLocationCoordinate2D {
    func asCLLocation() -> CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
