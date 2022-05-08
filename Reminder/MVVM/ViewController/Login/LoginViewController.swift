//
//  LoginViewController.swift
//  Reminder
//
//  Created by linhnd99 on 18/04/2022.
//

import UIKit
import AuthenticationServices
import GoogleSignIn

class LoginViewController: UIViewController {
    private lazy var userContext: UserContext = {
        return DIContainer.shared.resolve(UserContext.self)
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Action
    @IBAction func loginWithAppleButtonDidTap(_ sender: Any) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @IBAction func loginWithGoogleButtonDidTap(_ sender: Any) {
        let config = GIDConfiguration(clientID: Config.clientIDForGoogleSignIn)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
            if let error = error {
                print(error)
            } else {
                GIDSignIn.sharedInstance.signOut()
                self.userContext.loginGoogle(user: user!)
                self.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func closeButtonDidTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                self.userContext.loginApple(userID: appleIDCredential.user.standard(), username: appleIDCredential.email, fullname: appleIDCredential.fullName?.givenName)
            case let passwordCredential as ASPasswordCredential:
                self.userContext.loginApple(userID: passwordCredential.user.standard(), username: nil, fullname: nil)
            default:
                return
            }
        
        self.dismiss(animated: true)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("login with apple error \(error)")
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
