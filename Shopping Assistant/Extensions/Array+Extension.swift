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

extension Array where Element: Equatable {
    mutating func removeFirst(_ element: Element) {
        if let index = firstIndex(of: element) {
            remove(at: index)
        }
    }

    mutating func removeLast(_ element: Element) {
        if let index = lastIndex(of: element) {
            remove(at: index)
        }
    }
}
