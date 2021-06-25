//
//  LoginViewController.swift
//  cardTestApp
//
//  Created by Care Farrar on 6/3/21.
//
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import UIKit

class LoginViewController: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var GoogleSignInBtn: UIButton!
    @IBOutlet weak var CreateAccountBtn: UIButton!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().presentingViewController = self
    }

    @IBAction func showPassword(_ sender: UIButton) {
        passwordTxtField.isSecureTextEntry = !passwordTxtField.isSecureTextEntry
    }
    @IBAction func loginClicked(_ sender: UIButton) {
        guard let email = emailTxtField.text,
              let password = passwordTxtField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { [self] (result, error) in
            if let error = error {
                present(errorAlert(error: error), animated: true, completion: nil)
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func GoogleSignIn(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func firebaseLogin(_ credentail: AuthCredential) {
        Auth.auth().signIn(with: credentail) { [self] (result, error) in
            if let error = error {
                print("another error signing in \(error.localizedDescription)")
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
    }
}
