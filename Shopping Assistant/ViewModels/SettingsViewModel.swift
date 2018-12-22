import Foundation

protocol SettingsViewModelDelegate: AnyObject {
}

class SettingsViewModel {

    public weak var delegate: SettingsViewModelDelegate?

    public func onViewDidLoad() {
    }
}
