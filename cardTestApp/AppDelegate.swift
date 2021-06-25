//
//  AppDelegate.swift
//  cardTestApp
//
//  Created by Care Farrar on 5/10/21.
//
import Firebase
import FirebaseAuth
import GoogleSignIn
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        return true
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            debugPrint( error.localizedDescription + "google login failure")
        } else {
            guard let controller = GIDSignIn.sharedInstance()?.presentingViewController as? LoginViewController else { return }
            guard let authentication = user.authentication else { return }
            let credentail = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            controller.firebaseLogin(credentail)
        }
    }
}

