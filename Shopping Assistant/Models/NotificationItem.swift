import Foundation

class NotificationItem: NSSecureCoding {
    let id: String
    let name: String
    let lastUpdated: Date

    init(id: String, name: String, lastUpdated: Date) {
        self.id = id
        self.name = name
        self.lastUpdated = lastUpdated
    }

    convenience init?(from object: Any) {
        guard let dictionary = object as? [String: Any] else { return nil }
        guard let id = dictionary[NSCoderKeys.id] as? String else { return nil }
        guard let name = dictionary[NSCoderKeys.name] as? String else { return nil }
        guard let lastUpdated = dictionary[NSCoderKeys.lastUpdated] as? Date else { return nil }

        self.init(id: id, name: name, lastUpdated: lastUpdated)
    }

    // MARK: - NSSecureCoding

    static var supportsSecureCoding = true

    private struct NSCoderKeys {
        static let id = "id"
        static let name = "name"
        static let lastUpdated = "lastUpdated"
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id as NSString, forKey: NSCoderKeys.id)
        aCoder.encode(name as NSString, forKey: NSCoderKeys.name)
        aCoder.encode(lastUpdated as NSDate, forKey: NSCoderKeys.lastUpdated)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.id) as String? else { return nil }
        guard let name = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.name) as String? else { return nil }
        guard let lastUpdated = aDecoder.decodeObject(of: NSDate.self, forKey: NSCoderKeys.lastUpdated) as Date? else { return nil }

        self.init(id: id, name: name, lastUpdated: lastUpdated)
    }
}
