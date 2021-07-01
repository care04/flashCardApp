//
//  ViewController.swift
//  cardTestApp
//
//  Created by Care Farrar on 5/10/21.
//
import UserNotifications
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import UIKit

class ViewController: UIViewController {

    //IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newSectionText: UITextField!
    @IBOutlet weak var NewSectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var openNewSetViewButton: UIBarButtonItem!
    
    var sections = [Section]()
    var sets = [sectionSet]()
    var sectionCollection: CollectionReference!
    var currentSection = Section(name: "", documentId: "", createrId: "")
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionCollection = Firestore.firestore().collection(FireConstants.section)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener({ [self] (auth, user) in
            if user == nil {
                self.popControllerToLoginScreen(viewIdentifier: "LoginController")
                return
            }
            getData()
        })
    }
    
    func getData() {
        NewSectionViewHeightConstraint.constant = 0
        sectionCollection.addSnapshotListener { [self] (snap, error) in
            if let error = error {
                self.present(errorAlert(error: error), animated: true, completion: nil)
            }
            sections.removeAll()
            sections = parseSection(snapShot: snap)
            tableView.reloadData()
        }
    }
    func popControllerToLoginScreen(viewIdentifier: String) {
        let loginVC = storyboard!.instantiateViewController(withIdentifier: viewIdentifier)
        self.present(loginVC, animated: true, completion: nil)
    }
    @IBAction func LogoutAction(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            popControllerToLoginScreen(viewIdentifier: "LoginController")
        } catch let err as NSError {
            self.present(errorAlert(error: err), animated: true, completion: nil)
        }
    }
    
    @IBAction func AddSection(_ sender: UIBarButtonItem) {
        guard !tableView.isEditing else { return }
        if sender.title == "+" {
            sender.title = "Cancel"
            NewSectionViewHeightConstraint.constant = 150
        } else if sender.title == "Cancel" {
            sender.title = "+"
            newSectionText.text = ""
            NewSectionViewHeightConstraint.constant = 0
        }
    }
    
    @IBAction func saveClicked(_ sender: UIButton) {
        if newSectionText.text != "", let name = newSectionText.text, let user = Auth.auth().currentUser {
        sectionCollection.addDocument(data: [sectionInfo.name : name, sectionInfo.sectionCreateruid : user.uid]) { [self] (error) in
            if let error = error {
                present(errorAlert(error: error), animated: true, completion: nil)
            } else {
                newSectionText.text = ""
                NewSectionViewHeightConstraint.constant = 0
                openNewSetViewButton.title = "+"
            }
        }
    }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segues.sectiontoSet {
            guard let controller = segue.destination as? SetController else { return }
            guard let documentId = sender as? String else { return }
            controller.section = currentSection
            controller.sectionDocumentId = documentId
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource, SectionDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Auth.auth().currentUser?.displayName ?? "current user"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cells.sectionCell, for: indexPath) as? SectionCell else { return UITableViewCell() }
        cell.fillCell(section: sections[indexPath.row], delegate: self)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSection = sections[indexPath.row]
        performSegue(withIdentifier: segues.sectiontoSet, sender: sections[indexPath.row].documentId)
    }
    
    func deleteCards(section: Section) {
        sectionCollection.document(section.documentId).collection(FireConstants.set).addSnapshotListener { [self] (snap, error) in
        if let error = error {
            self.present(errorAlert(error: error), animated: true, completion: nil)
        }
            guard let snap = snap else { return }
            for document in snap.documents {
                delete(collection: sectionCollection.document(section.documentId).collection(FireConstants.set).document(document.documentID).collection(FireConstants.card)) { error in
                    if let error = error {
                        self.present(errorAlert(error: error), animated: true, completion: nil)
                    } else {
                        delete(collection: sectionCollection.document(section.documentId).collection(FireConstants.set)) { error in
                            if let error = error {
                                self.present(errorAlert(error: error), animated: true, completion: nil)
                            } else {
                                sectionCollection.document(section.documentId).delete { error in
                                    if let error = error {
                                        self.present(errorAlert(error: error), animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func trashTapped(section: Section) {
        deleteCards(section: section)
    }
    
    func delete(collection: CollectionReference, batchSize: Int = 100, completion: @escaping (Error?) -> ()) {
        collection.limit(to: batchSize).getDocuments { (docset, error) in
            guard let docset = docset else {
                completion(nil)
                return
            }
            guard docset.count > 0 else {
                completion(nil)
                return
            }
            let batch = collection.firestore.batch()
            docset.documents.forEach { batch.deleteDocument($0.reference) }
            batch.commit { [self] (batchError) in
                if let batchError = batchError {
                    completion(batchError)
                } else {
                    delete(collection: collection, batchSize: batchSize, completion: completion)
                }
            }
        }
    }
}
