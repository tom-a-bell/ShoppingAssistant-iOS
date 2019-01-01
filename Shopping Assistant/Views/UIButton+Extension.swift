import UIKit

extension UIButton {
    @IBInspectable
    var buttonColor: UIColor? {
        get { return backgroundColor }
        set {
            backgroundColor = newValue
            setBackgroundColor(newValue, for: .normal)
        }
    }

    @IBInspectable
    var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }

    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        if let color = color {
            setBackgroundImage(image(with: color), for: state)
            clipsToBounds = true
        } else {
            setBackgroundImage(nil, for: state)
        }
    }

    private func image(with color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)

        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}
