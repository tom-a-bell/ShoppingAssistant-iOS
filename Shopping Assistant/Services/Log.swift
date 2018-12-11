import Foundation
import JustLog

class Log {
    static func configure() {
        let logger = Logger.shared

        // Default user info to be added to each log entry
        let appName = Bundle.main.displayName ?? "Unknown"
        logger.defaultUserInfo = ["app": appName, "environment": "development", "session": UUID().uuidString]

        logger.logzioToken = LoggingConfiguration.token
        logger.logstashHost = LoggingConfiguration.host
        logger.logstashPort = LoggingConfiguration.port
        logger.logstashTimeout = 5

        logger.enableFileLogging = false
        logger.logLogstashSocketActivity = false

        logger.setup()
    }

    static func forceSendLogs(_ application: UIApplication) {
        var identifier = UIBackgroundTaskIdentifier(rawValue: 0)

        identifier = application.beginBackgroundTask(expirationHandler: {
            application.endBackgroundTask(identifier)
            identifier = UIBackgroundTaskIdentifier.invalid
        })

        Logger.shared.forceSend { _ in
            application.endBackgroundTask(identifier)
            identifier = UIBackgroundTaskIdentifier.invalid
        }
    }

    static func debug(_ message: String, error: Error? = nil, userInfo: [String: Any]? = nil) {
        Logger.shared.debug(message, error: error as NSError?, userInfo: userInfo)
    }

    static func info(_ message: String, error: Error? = nil, userInfo: [String: Any]? = nil) {
        Logger.shared.info(message, error: error as NSError?, userInfo: userInfo)
    }

    static func warning(_ message: String, error: Error? = nil, userInfo: [String: Any]? = nil) {
        Logger.shared.warning(message, error: error as NSError?, userInfo: userInfo)
    }

    static func error(_ message: String, error: Error? = nil, userInfo: [String: Any]? = nil) {
        Logger.shared.error(message, error: error as NSError?, userInfo: userInfo)
    }
}
