import AuthenticationServices
import CryptoKit
import Firebase
import Foundation

class AuthenticationService {
    static let shared = AuthenticationService()
    private init() {}

    var currentNonce: String?

    func signUp(
        email: String, password: String, completion: @escaping (Result<User, Error>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = authResult?.user {
                completion(.success(user))
            } else {
                completion(
                    .failure(
                        NSError(
                            domain: "AuthenticationError", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])))
            }
        }
    }

    func signIn(
        email: String, password: String, completion: @escaping (Result<User, Error>) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = authResult?.user {
                completion(.success(user))
            } else {
                completion(
                    .failure(
                        NSError(
                            domain: "AuthenticationError", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])))
            }
        }
    }

    func signIn(
        with credential: AuthCredential, completion: @escaping (Result<User, Error>) -> Void
    ) {
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = authResult?.user {
                completion(.success(user))
            } else {
                completion(
                    .failure(
                        NSError(
                            domain: "AuthenticationError", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])))
            }
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(
                .failure(
                    NSError(
                        domain: "AuthenticationError", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }

        user.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func ensureUserDocument(for user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)

        userRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let document = document, document.exists {
                // User document already exists
                completion(.success(()))
            } else {
                // Create new user document
                let userData: [String: Any] = [
                    "email": user.email ?? "",
                    "createdAt": FieldValue.serverTimestamp(),
                    "userId": user.uid,  // Add the user's UID to the document
                ]

                userRef.setData(userData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }

    func startSignInWithAppleFlow() -> ASAuthorizationAppleIDRequest {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        return request
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
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
}
