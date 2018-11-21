import Foundation

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedElements = [Element: Bool]()

        return filter {
            addedElements.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
