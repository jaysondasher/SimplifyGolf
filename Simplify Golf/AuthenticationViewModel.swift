import Foundation
import Firebase
import Combine
import AuthenticationServices

class AuthenticationViewModel: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var user: User?
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: String?
    @Published var appleSignInEmail: String?
    @Published var userIdentifier: String?
    
    private let authService = AuthenticationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupFirebaseAuthStateListener()
    }
    
    private func setupFirebaseAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                self?.user = user
                self?.appleSignInEmail = user?.email
            }
        }
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
    
    func signInWithApple() {
        let request = authService.startSignInWithAppleFlow()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "AuthenticationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in"])))
            return
        }
        
        deleteUserData(userId: user.uid) { [weak self] result in
            switch result {
            case .success:
                user.delete { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        self?.isAuthenticated = false
                        self?.user = nil
                        self?.appleSignInEmail = nil
                        if let identifier = self?.userIdentifier {
                            UserDefaults.standard.removeObject(forKey: "AppleSignInEmail_\(identifier)")
                        }
                        self?.userIdentifier = nil
                        completion(.success(()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func deleteUserData(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("rounds").whereField("userId", isEqualTo: userId).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let batch = db.batch()
            snapshot?.documents.forEach { document in
                batch.deleteDocument(document.reference)
            }
            
            batch.commit { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func getCurrentUserEmail() -> String? {
        if let email = Auth.auth().currentUser?.email {
            return email
        } else if let identifier = userIdentifier {
            return UserDefaults.standard.string(forKey: "AppleSignInEmail_\(identifier)")
        }
        return nil
    }
}

extension AuthenticationViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = authService.currentNonce else {
                self.error = "Invalid state: A login callback was received, but no login request was sent."
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                self.error = "Unable to fetch identity token"
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                self.error = "Unable to serialize token string from data: \(appleIDToken.debugDescription)"
                return
            }
            
            self.userIdentifier = appleIDCredential.user
            if let email = appleIDCredential.email {
                self.appleSignInEmail = email
                UserDefaults.standard.set(email, forKey: "AppleSignInEmail_\(appleIDCredential.user)")
            } else {
                self.appleSignInEmail = UserDefaults.standard.string(forKey: "AppleSignInEmail_\(appleIDCredential.user)")
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            authService.signIn(with: credential) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let user):
                        self?.user = user
                        self?.isAuthenticated = true
                        if self?.appleSignInEmail == nil {
                            self?.appleSignInEmail = user.email
                        }
                    case .failure(let error):
                        self?.error = error.localizedDescription
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.error = "Sign in with Apple failed: \(error.localizedDescription)"
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
}
