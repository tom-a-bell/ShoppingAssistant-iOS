import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!

    private let viewModel = MapViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

        viewModel.delegate = self
        viewModel.onViewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let placeMarker = marker as? PlaceMarker else { return nil }
        guard let infoView = UIView.viewFromNib(named: "MarkerInfoView") as? MarkerInfoView else { return nil }

        infoView.nameLabel.text = placeMarker.place.name

        return infoView
    }
}

// MARK: - MapViewModelDelegate
extension MapViewController: MapViewModelDelegate {
    func enableCurrentLocation() {
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }

    func centreMapOn(_ location: CLLocation) {
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        viewModel.findNearbyPlaces(coordinate: location.coordinate)
    }

    func markPlaces(_ places: [GooglePlace]) {
        places.forEach {
            let marker = PlaceMarker(place: $0)
            marker.map = mapView
        }
    }
}
