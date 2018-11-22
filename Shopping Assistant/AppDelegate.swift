import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Log.configure()

        GoogleMapsService.shared.initialize()
        LocationManager.shared.initialize()

        LocationManager.shared.requestAuthorization()
            .then(handleLocationAuthorizationResponse)
            .catch(handleError)

        NotificationsManager.shared.requestAuthorization()
            .then(handleNotificationAuthorizationResponse)
            .catch(handleError)

        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return AmazonClientManager.shared.application(application, open: url, options: options)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions
        // (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore
        // your application to its current state in case it is terminated later. If your application supports background execution, this method is
        // called instead of applicationWillTerminate: when the user quits.

        Log.forceSendLogs(application)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from background to active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive.
        // If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:

        Log.forceSendLogs(application)
    }
}

extension AppDelegate {
    func handleLocationAuthorizationResponse(authorizationStatus: CLAuthorizationStatus) {
        if authorizationStatus == .authorizedAlways { return }

        let message = "To enable background location tracking in the future, visit:\nSettings > Shopping List > Location"
        let warningAlert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default)

        warningAlert.addAction(dismissAction)

        window?.rootViewController?.present(warningAlert, animated: true, completion: nil)
    }

    func handleNotificationAuthorizationResponse(authorizationIsGranted: Bool) {
        if authorizationIsGranted { return }

        let message = "To enable notifications in the future, visit:\nSettings > Shopping List > Notifications"
        let warningAlert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default)

        warningAlert.addAction(dismissAction)

        window?.rootViewController?.present(warningAlert, animated: true, completion: nil)
    }

    func handleError(error: Error) {
        Log.error("Error while requesting authorization:", error: error)

        let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default)

        errorAlert.addAction(dismissAction)

        window?.rootViewController?.present(errorAlert, animated: true, completion: nil)
    }
}
