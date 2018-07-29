import UIKit

extension UIView {

    class func viewFromNib(named name: String) -> UIView? {
        let views = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
        return views?.first as? UIView
    }

    func fadeOut(_ duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: { self.alpha = 0.0 })
    }

    func fadeIn(_ duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: { self.alpha = 1.0 })
    }
}
