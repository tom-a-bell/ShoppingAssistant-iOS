import Foundation

struct ResponseError: Error {
    let statusCode: Int
    let message: String
}

extension ResponseError: LocalizedError {
    public var errorDescription: String? {
        return "Response: \(message) (\(statusCode))"
    }
}
