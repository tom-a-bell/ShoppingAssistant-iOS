import Stylist
import UIKit

extension Stylist {
    private var themeUrl: URL {
        return URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Resources")
            .appendingPathComponent("Style.yaml")
    }

    func loadTheme() {
        watch(url: themeUrl, animateChanges: true) { error in
            Log.error("Error loading theme from \(self.themeUrl.absoluteString)\n\(error.localizedDescription)", error: error)
            self.logError(error)
        }
    }

    private func logError(_ error: ThemeError) {
        switch error {
        case let .invalidVariable(name, variable):
            Log.error("Invalid variable name: \(name), variable: \(variable)")
        case let .invalidStyleReference(style, reference):
            Log.error("Invalid style reference - style: \(style), reference: \(reference)")
        case let .invalidPropertyState(name, state):
            Log.error("Invalid property state - name: \(name), state: \(state)")
        case let .invalidSizeClass(name, sizeClass):
            Log.error("Invalid size class - name: \(name), sizeClass: \(sizeClass)")
        case let .invalidStyleContext(context):
            Log.error("Invalid style context: \(context)")
        case let .invalidStyleSelector(selector):
            Log.error("Invalid style selector: \(selector)")
        case let .invalidDevice(name, device):
            Log.error("Invalid device - name: \(name), device: \(device)")
        case let .styleReferenceCycle(references):
            Log.error("Style reference cycle - references: \(references.debugDescription)")
        default:
            Log.error(error.localizedDescription)
        }
    }
}

@IBDesignable extension UIViewController {
    @IBInspectable var styleName: String? {
        get { return style }
        set { style = newValue }
    }
}

@IBDesignable extension UIView {
    @IBInspectable var styleName: String? {
        get { return style }
        set { style = newValue }
    }
}

@IBDesignable extension UIBarItem {
    @IBInspectable var styleName: String? {
        get { return style }
        set { style = newValue }
    }
}
