import Foundation

extension Bundle {
    // Name of the app as it appears on the homescreen
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
            object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String
    }
}
