import UIKit
import GoogleMaps

class MapViewController<ViewModel: MapViewModel>: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var mapView: GMSMapView!

    lazy private var infoView: MarkerInfoView? = { UIView.viewFromNib(named: "MarkerInfoView") as? MarkerInfoView }()

    public var viewModel: ViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

        viewModel.delegate = self
        viewModel.onViewDidLoad()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? AddLocationViewController,
            let place = infoView?.place else { return }

        destination.viewModel = AddLocationViewModel(with: Location.from(place))
    }

    // MARK: - GMSMapViewDelegate

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let placeMarker = marker as? PlaceMarker, let infoView = infoView else { return false }

        infoView.center = mapView.projection.point(for: placeMarker.position)
        infoView.place = placeMarker.place
        infoView.delegate = self

        self.infoView = infoView
        view.addSubview(infoView)

        return false
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        guard let coordinate = infoView?.place?.location.coordinate else { return }
        infoView?.center = mapView.projection.point(for: coordinate)
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let location = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
        viewModel.mapDidCentreAt(location)
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoView?.removeFromSuperview()
        infoView?.place = nil
    }

    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        _ = self.mapView(mapView, didTap: PlaceMarker(withId: placeID, name: name, location: location))
        mapView.animate(toLocation: location)
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
    }

    func markPlaces(_ places: [GooglePlace]) {
        places.forEach {
            let marker = PlaceMarker(place: $0)
            marker.map = mapView
        }
    }

    func showLoadingSpinner() {
        spinner.startAnimating()
    }

    func hideLoadingSpinner() {
        spinner.stopAnimating()
    }

    func showErrorMessage(_ message: String) {
        let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default)

        errorAlert.addAction(dismissAction)

        self.present(errorAlert, animated: true, completion: nil)
    }
}

// MARK: - MarkerInfoViewDelegate
extension MapViewController: MarkerInfoViewDelegate {
    func addLocation(for place: GooglePlace) {
        performSegue(withIdentifier: "AddLocation", sender: self)
    }
}
