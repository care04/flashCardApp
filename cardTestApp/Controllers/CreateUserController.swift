//
//  CreateUserController.swift
//  cardTestApp
//
//  Created by Care Farrar on 6/4/21.
//
import FirebaseFirestore
import FirebaseAuth
import UIKit

class CreateUserController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createUserButton: UIButton!
    @IBOutlet weak var cancel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundButtons(buttons: [createUserButton,cancel])
    }
    
    @IBAction func createUser(_ sender: UIButton) {
        guard let username = usernameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              username != "", email != "", password != ""
            else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("error creating user \(error.localizedDescription)")
            } else {
                let user = result?.user
                let changeRequest = user?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.commitChanges(completion: { (error) in
                    if let error = error {
                        debugPrint("error changing display name \(error.localizedDescription)")
                    }
                })
                guard let userId = user?.uid else { return }
                Firestore.firestore().collection(User.userRef).document(userId).setData([User.username : username]) {
                    (error) in
                    if let error = error {
                        print("error setting usernameData \(error.localizedDescription)")
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func cancelCreate(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
