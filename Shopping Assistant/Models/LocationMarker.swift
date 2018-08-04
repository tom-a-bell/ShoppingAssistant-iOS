import UIKit
import GoogleMaps

class LocationMarker: GMSCircle {

    let location: Location
    let color: UIColor

    init(location: Location, withColor color: UIColor = .purple) {
        self.location = location
        self.color = color
        super.init()

        position = location.coordinate.coordinate
        radius = location.radius

        fillColor = color.withAlphaComponent(0.25)
        strokeColor = color.withAlphaComponent(1)
        strokeWidth = 1
    }
}
