import Foundation
import AWSCore
import AWSCognito

class AmazonClientManager: NSObject {

    static let shared = AmazonClientManager()

    private var completionHandler: ((AWSTask<NSString>) -> Void)?
    private var credentialsProvider: AWSCognitoCredentialsProvider?

    // Sends the appropriate URL
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[.sourceApplication] as? String
        return AIMobileLib.handleOpen(url, sourceApplication: sourceApplication)
    }

    func isLoggedIn() -> Bool {
        return credentialsProvider?.identityId != nil
    }

    func login(completionHandler: @escaping (AWSTask<NSString>) -> Void) {
        self.completionHandler = completionHandler
        loginWithAmazon()
    }

    func logout(completionHandler: @escaping (AWSTask<NSString>) -> Void) {
        logoutFromAmazon()

        // Wipe credentials
//        credentialsProvider?.logins = nil
        AWSCognito.default().wipe()
        credentialsProvider?.clearKeychain()

        AWSTask(result: nil).continueWith(block: completionHandler)
    }

    func resumeSession(completionHandler: @escaping (AWSTask<NSString>) -> Void) {
        self.completionHandler = completionHandler
        loginWithAmazon()

        if credentialsProvider == nil {
            completeLogin(withToken: "")
        }
    }

    func loginWithAmazon() {
        print("Logging in with Amazon...")
        AIMobileLib.authorizeUser(forScopes: ["profile"], delegate: self)
    }

    func logoutFromAmazon() {
        AIMobileLib.clearAuthorizationState(self)
    }

    func completeLogin(withToken token: Any) {
        if credentialsProvider == nil {
            credentialsProvider = initializeClient(withToken: token)
            credentialsProvider?.getIdentityId().continueWith(block: completionHandler!)
        } else {
            credentialsProvider?.setIdentityProviderManagerOnce(AmazonIdentityProviderManager(withToken: token))
//            credentialsProvider?.refresh().continueWith(block: completionHandler!)
        }
    }

    func initializeClient(withToken token: Any) -> AWSCognitoCredentialsProvider {
        print("Initializing client...")

        AWSDDLog.sharedInstance.logLevel = .verbose

        let identityProviderManager = AmazonIdentityProviderManager(withToken: token)
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: AWSConfiguration.regionType,
            identityPoolId: AWSConfiguration.identityPoolId,
            identityProviderManager: identityProviderManager)
        let configuration = AWSServiceConfiguration(
            region: AWSConfiguration.regionType,
            credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        return credentialsProvider
    }
}

// MARK:- AIAuthenticationDelegate
extension AmazonClientManager: AIAuthenticationDelegate {
    func requestDidSucceed(_ apiResult: APIResult!) {
        if apiResult.api == API.authorizeUser {
            AIMobileLib.getAccessToken(forScopes: ["profile"], withOverrideParams: nil, delegate: self)
        } else if apiResult.api == API.getAccessToken {
            if let token = apiResult.result {
                completeLogin(withToken: token)
            }
        }
    }

    func requestDidFail(_ errorResponse: APIError!) {
        print("Error logging in with Amazon: " + errorResponse.description)
        AWSTask(result: nil).continueWith(block: completionHandler!)
    }
}

// MARK:- AWSIdentityProviderManager
class AmazonIdentityProviderManager: NSObject, AWSIdentityProviderManager {
    private let token: Any

    init(withToken token: Any) {
        self.token = token
    }

    func logins() -> AWSTask<NSDictionary> {
        return AWSTask<NSDictionary>(result: [AWSIdentityProviderLoginWithAmazon: token])
    }
}
