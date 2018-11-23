import Foundation

extension UUID {
    init?(from string: String) {
        self.init(uuidString: string)
    }

    var stringValue: String {
        return uuidString.lowercased()
    }
}
