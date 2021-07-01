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
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        FirebaseApp.configure()
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        return true
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Remote is currently unavailable: \(error.localizedDescription)")
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.forwardTokenToServer(token: deviceToken)
    }
    
    func forwardTokenToServer(token: Data) {
        let tokenComponents = token.map { data in String(format: "%02.2hhx", data)}
        let deviceTokenString = tokenComponents.joined()
        let queryItems = [URLQueryItem(name: "deviceToken", value: deviceTokenString)]
        var urlComps = URLComponents(string: "www.exsample.com/register")
        urlComps?.queryItems = queryItems
        guard let url = urlComps?.url else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
        }
        task.resume()
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

