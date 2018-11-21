import Foundation

// swiftlint:disable control_statement
extension Dictionary where Key: Comparable, Value: Equatable {
    func subtracting(_ other: [Key: Value]) -> [Key: Value] {
        return reduce(into: [:]) { result, element in
            let (key, value) = element
            if (other[key] != value) {
                result[key] = value
            }
        }
    }
}
