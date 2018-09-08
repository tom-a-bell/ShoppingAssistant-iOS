import Foundation
import AWSCore
import AWSCognito
import Promises

class AmazonClientManager: NSObject {

    static let shared = AmazonClientManager()

    private var credentialsProvider: AWSCognitoCredentialsProvider?

    private var loginPromise: Promise<Void>?
    private var logoutPromise: Promise<Void>?

    // Sends the appropriate URL
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[.sourceApplication] as? String
        return AIMobileLib.handleOpen(url, sourceApplication: sourceApplication)
    }

    func isLoggedIn() -> Bool {
        return credentialsProvider?.identityId != nil
    }

    func login() -> Promise<Void> {
        guard logoutPromise == nil else { return Promise(LogoutInProgressError()) }
        if let loginPromise = loginPromise { return loginPromise }

        loginPromise = Promise<Void>.pending()
        loginWithAmazon()

        return loginPromise!
    }

    func logout() -> Promise<Void> {
        guard loginPromise == nil else { return Promise(LoginInProgressError()) }
        if let logoutPromise = logoutPromise { return logoutPromise }

        logoutPromise = Promise<Void>.pending()
        logoutFromAmazon()

        return logoutPromise!
    }

    func resumeSession() -> Promise<Void> {
        guard logoutPromise == nil else { return Promise(LogoutInProgressError()) }
        if let loginPromise = loginPromise { return loginPromise }

        loginPromise = Promise<Void>.pending()
        loginWithAmazon()

        if credentialsProvider == nil {
            completeLogin(withToken: "")
        }

        return loginPromise!
    }

    private func loginWithAmazon() {
        print("Logging in with Amazon...")
        AIMobileLib.authorizeUser(forScopes: ["profile"], delegate: self)
    }

    private func logoutFromAmazon() {
        print("Logging out from Amazon...")
        AIMobileLib.clearAuthorizationState(self)
    }

    private func completeLogin(withToken token: Any) {
        if credentialsProvider == nil {
            credentialsProvider = initializeClient(withToken: token)
            credentialsProvider?.getIdentityId().continueWith { _ in self.loginPromise?.fulfill(()) }
        } else {
            credentialsProvider?.setIdentityProviderManagerOnce(AmazonIdentityProviderManager(withToken: token))
        }
    }

    private func completeLogout() {
        // Wipe credentials from cache and keychain
        AWSCognito.default().wipe()
        credentialsProvider?.clearKeychain()
        credentialsProvider?.clearCredentials()

        logoutPromise?.fulfill(())
    }

    private func initializeClient(withToken token: Any) -> AWSCognitoCredentialsProvider {
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

// MARK: - AIAuthenticationDelegate
extension AmazonClientManager: AIAuthenticationDelegate {
    func requestDidSucceed(_ apiResult: APIResult!) {
        switch apiResult.api {
        case .authorizeUser:
            AIMobileLib.getAccessToken(forScopes: ["profile"], withOverrideParams: nil, delegate: self)
        case .getAccessToken:
            if let token = apiResult.result {
                completeLogin(withToken: token)
            }
        case .clearAuthorizationState:
            completeLogout()
        default:
            return
        }
    }

    func requestDidFail(_ errorResponse: APIError!) {
        print("Error logging in with Amazon: " + errorResponse.description)
        let error = AmazonApiResponseError(errorResponse)

        if let loginPromise = loginPromise {
            loginPromise.reject(error)
        }
        if let logoutPromise = logoutPromise {
            logoutPromise.reject(error)
        }
    }
}

// MARK: - AWSIdentityProviderManager
class AmazonIdentityProviderManager: NSObject, AWSIdentityProviderManager {
    private let token: Any

    init(withToken token: Any) {
        self.token = token
    }

    func logins() -> AWSTask<NSDictionary> {
        return AWSTask<NSDictionary>(result: [AWSIdentityProviderLoginWithAmazon: token])
    }
}

// MARK: - AmazonApiResponseError
struct AmazonApiResponseError: LocalizedError {
    let error: AIError
    let errorDescription: String

    init(_ apiError: APIError) {
        error = apiError.error
        errorDescription = apiError.description
    }
}

// MARK: - LoginInProgressError
struct LoginInProgressError: LocalizedError {
    public var errorDescription: String? {
        return "Cannot logout while login is in progress"
    }
}

// MARK: - LogoutInProgressError
struct LogoutInProgressError: LocalizedError {
    public var errorDescription: String? {
        return "Cannot login while logout is in progress"
    }
}
