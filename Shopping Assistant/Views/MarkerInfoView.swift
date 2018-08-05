import UIKit

protocol MarkerInfoViewDelegate {
    func addLocation(for place: GooglePlace)
}

class MarkerInfoView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addLocationbutton: UIButton!

    var delegate: MarkerInfoViewDelegate?

    var place: GooglePlace? {
        didSet { nameLabel.text = place?.name }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        layer.borderColor = UIColor.purple.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 4

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 4, height: 4)
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 4
    }

    // MARK: - Actions

    @IBAction func addLocation() {
        guard let place = place else { return }
        delegate?.addLocation(for: place)
    }
}
