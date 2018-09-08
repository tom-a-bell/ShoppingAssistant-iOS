import Foundation

extension String {
    func sentenceCased() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
}
