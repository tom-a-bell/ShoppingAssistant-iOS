import UIKit

extension UIContextualAction {
    convenience init(withHandler handler: @escaping Handler, style: Style, title: String?, image: UIImage?, backgroundColor: UIColor?) {
        self.init(style: style, title: title, handler: handler)
        self.backgroundColor = backgroundColor
        self.image = image
    }
}
