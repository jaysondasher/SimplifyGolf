import AuthenticationServices
import CryptoKit
import Firebase
import SwiftUI

class AuthenticationViewModel: NSObject, ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated = false
    @Published var user: User?
    @Published var error: String?
    @Published var isLoading = false
    @Published var appleSignInEmail: String?
    @Published var userIdentifier: String?

    private let authService = AuthenticationService.shared
    private var currentNonce: String?

    override init() {
        super.init()
        checkAuthStatus()
    }

    func checkAuthStatus() {
        isAuthenticated = Auth.auth().currentUser != nil
        user = Auth.auth().currentUser
    }

    func signUp() {
        isLoading = true
        error = nil
        authService.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let user):
                    self?.user = user
                    self?.isAuthenticated = true
                    self?.ensureUserDocument(for: user)
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }

    func signIn() {
        isLoading = true
        error = nil
        authService.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let user):
                    self?.user = user
                    self?.isAuthenticated = true
                    self?.ensureUserDocument(for: user)
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }

    func signOut() {
        do {
            try authService.signOut()
            isAuthenticated = false
            user = nil
            appleSignInEmail = nil
            userIdentifier = nil
        } catch {
            self.error = error.localizedDescription
        }
    }

    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        authService.deleteAccount { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isAuthenticated = false
                    self?.user = nil
                    self?.appleSignInEmail = nil
                    self?.userIdentifier = nil
                    completion(.success(()))
                case .failure(let error):
                    self?.error = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }

    private func ensureUserDocument(for user: User) {
        authService.ensureUserDocument(for: user) { [weak self] result in
            switch result {
            case .success:
                print("User document ensured in Firestore")
            case .failure(let error):
                print("Error ensuring user document: \(error.localizedDescription)")
                self?.error = "Error updating user information"
            }
        }
    }

    func getCurrentUserEmail() -> String? {
        if let email = Auth.auth().currentUser?.email {
            return email
        } else if let identifier = userIdentifier {
            return UserDefaults.standard.string(forKey: "AppleSignInEmail_\(identifier)")
        } else {
            return UserViewModel.shared.getUserEmail()
        }
    }

    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
            {
                guard let nonce = currentNonce else {
                    fatalError(
                        "Invalid state: A login callback was received, but no login request was sent."
                    )
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print(
                        "Unable to serialize token string from data: \(appleIDToken.debugDescription)"
                    )
                    return
                }

                let credential = OAuthProvider.credential(
                    withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
                signInWithCredential(credential, appleIDCredential: appleIDCredential)
            }
        case .failure(let error):
            self.error = error.localizedDescription
        }
    }

    private func signInWithCredential(
        _ credential: AuthCredential, appleIDCredential: ASAuthorizationAppleIDCredential
    ) {
        authService.signIn(with: credential) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.user = user
                    self?.isAuthenticated = true
                    self?.ensureUserDocument(for: user)
                    if self?.appleSignInEmail == nil {
                        self?.appleSignInEmail = appleIDCredential.email
                        self?.userIdentifier = appleIDCredential.user
                        if let email = self?.appleSignInEmail, let identifier = self?.userIdentifier
                        {
                            UserDefaults.standard.set(
                                email, forKey: "AppleSignInEmail_\(identifier)")
                        }
                    }
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array(
            "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

extension AuthenticationViewModel: ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding
{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        handleSignInWithAppleCompletion(.success(authorization))
    }

    func authorizationController(
        controller: ASAuthorizationController, didCompleteWithError error: Error
    ) {
        handleSignInWithAppleCompletion(.failure(error))
    }
}
