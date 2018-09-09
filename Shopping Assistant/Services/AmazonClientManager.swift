import Foundation
import AWSCore
import AWSCognito
import Promises

class AmazonClientManager: NSObject {

    static let shared = AmazonClientManager()

    private var credentialsProvider: AWSCognitoCredentialsProvider?

    private var loginPromise: Promise<Void>?
    private var loginInProgress = false

    private var logoutPromise: Promise<Void>?
    private var logoutInProgress = false

    // Sends the appropriate URL
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[.sourceApplication] as? String
        return AIMobileLib.handleOpen(url, sourceApplication: sourceApplication)
    }

    func isLoggedIn() -> Bool {
        return credentialsProvider?.identityId != nil
    }

    func login() -> Promise<Void> {
        guard !loginInProgress, !logoutInProgress else { return Promise(LoginRequestInProgressError()) }

        let promise = pendingLoginPromise()
        loginWithAmazon()

        return promise
    }

    func logout() -> Promise<Void> {
        guard !loginInProgress, !logoutInProgress else { return Promise(LoginRequestInProgressError()) }

        let promise = pendingLogoutPromise()
        logoutFromAmazon()

        return promise
    }

    func resumeSession() -> Promise<Void> {
        guard !loginInProgress, !logoutInProgress else { return Promise(LoginRequestInProgressError()) }

        let promise = pendingLoginPromise()
        getAccessToken()

        return promise
    }

    private func pendingLoginPromise() -> Promise<Void> {
        loginInProgress = true
        loginPromise = Promise<Void>.pending()
        return loginPromise!.always { [weak self] in self?.loginInProgress = false }
    }

    private func pendingLogoutPromise() -> Promise<Void> {
        logoutInProgress = true
        logoutPromise = Promise<Void>.pending()
        return logoutPromise!.always { [weak self] in self?.logoutInProgress = false }
    }

    private func loginWithAmazon() {
        print("Logging in with Amazon...")
        AIMobileLib.authorizeUser(forScopes: ["profile"], delegate: self)
    }

    private func logoutFromAmazon() {
        print("Logging out from Amazon...")
        AIMobileLib.clearAuthorizationState(self)
    }

    private func getAccessToken() {
        AIMobileLib.getAccessToken(forScopes: ["profile"], withOverrideParams: nil, delegate: self)
    }

    private func completeLogin(withToken token: Any) {
        initializeOrUpdateCredentialsProvider(token)
        credentialsProvider?.getIdentityId().continueWith { task in
            task.isFaulted ? self.loginPromise?.reject(task.error!) : self.loginPromise?.fulfill(())
        }
    }

    private func completeLogout() {
        // Wipe credentials from cache and keychain
        AWSCognito.default().wipe()
        credentialsProvider?.clearKeychain()
        credentialsProvider?.clearCredentials()

        logoutPromise?.fulfill(())
    }

    private func initializeOrUpdateCredentialsProvider(_ token: Any) {
        if let credentialsProvider = credentialsProvider {
            credentialsProvider.setIdentityProviderManagerOnce(AmazonIdentityProviderManager(withToken: token))
        } else {
            credentialsProvider = initializeClient(withToken: token)
        }
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
            getAccessToken()
        case .getAccessToken:
            completeLogin(withToken: apiResult.result)
        case .clearAuthorizationState:
            completeLogout()
        default:
            return
        }
    }

    func requestDidFail(_ errorResponse: APIError!) {
        print("Error logging in with Amazon:", errorResponse.error.message)
        let error = AmazonApiResponseError(errorResponse)

        if loginInProgress, let loginPromise = loginPromise {
            loginPromise.reject(error)
        }

        if logoutInProgress, let logoutPromise = logoutPromise {
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

    init(_ apiError: APIError) {
        error = apiError.error
    }

    public var errorDescription: String? {
        return error.message
    }
}

// MARK: - LoginRequestInProgressError
struct LoginRequestInProgressError: LocalizedError {
    public var errorDescription: String? {
        return "Login request is currently in progress"
    }
}
