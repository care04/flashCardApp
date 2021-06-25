//
//  SetController.swift
//  cardTestApp
//
//  Created by Care Farrar on 5/10/21.
//
import FirebaseAuth
import FirebaseFirestore
import UIKit

class SetController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var setNameText: UITextField!
    @IBOutlet weak var newNameHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var newCardViewHeight: NSLayoutConstraint!
    @IBOutlet weak var openAddViewButton: UIBarButtonItem!
    @IBOutlet weak var termTextField: UITextField!
    @IBOutlet weak var definitionTextField: UITextField!
    
    var sectionDocumentId: String!
    var sets = [sectionSet]()
    var currentSet: sectionSet?
    var toSectionDocRef: DocumentReference!
    var section: Section!
    
    override func viewDidLoad() {
        if section.createrId != Auth.auth().currentUser?.uid {
            openAddViewButton.isEnabled = false
            openAddViewButton.title = ""
        } else {
            openAddViewButton.isEnabled = true
            openAddViewButton.title = "+"
        }
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationItem.title = section.name + " " + "Sets"
        newNameHeightAnchor.constant = 0
        newCardViewHeight.constant = 0
        toSectionDocRef = Firestore.firestore().collection(FireConstants.section).document(sectionDocumentId)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        getSet(setDocumentId: sectionDocumentId)
    }
    
    @IBAction func cancelNewCardClicked(_ sender: Any) {
        definitionTextField.text?.removeAll()
        termTextField.text?.removeAll()
        newCardViewHeight.constant = 0
    }
    
    @IBAction func saveCardClicked(_ sender: UIButton) {
        guard let set = currentSet, let term = termTextField.text, let definition = definitionTextField.text else { return }
        toSectionDocRef.collection(FireConstants.set).document(set.documentId).collection(FireConstants.card).addDocument(data: [cardInfo.term : term, cardInfo.definition : definition, cardInfo.passed : false ]) { [self] (error) in
            if let error = error {
                debugPrint("error saving new card \(error.localizedDescription)")
            }
            definitionTextField.text?.removeAll()
            termTextField.text?.removeAll()
            newCardViewHeight.constant = 0
        }
    }
    @IBAction func addSetBarClicked(_ sender: UIBarItem) {
        guard !tableView.isEditing else { return }
        if sender.title == "+" {
            sender.title = "Cancel"
            newNameHeightAnchor.constant = 150
        } else if sender.title == "Cancel" {
            sender.title = "+"
            setNameText.text = ""
            newNameHeightAnchor.constant = 0
        }
    }
    
    @IBAction func EditSets(_ sender: UIBarButtonItem) {
        guard openAddViewButton.title == "+" else { return }
        if tableView.isEditing {
            tableView.isEditing = false
            sender.title = "Edit"
        } else {
            tableView.isEditing = true
            sender.title = "Done"
        }
    }
    
    @IBAction func saveSet(_ sender: Any) {
        if setNameText.text != "", let name = setNameText.text {
            toSectionDocRef.collection(FireConstants.set).addDocument(data: [setInfo.name : name]) { [self] (error) in
                if let error = error {
                    print("error saving set:", error.localizedDescription)
                } else {
                    setNameText.text = ""
                    newNameHeightAnchor.constant = 0
                    openAddViewButton.title = "+"
                }
            }
        }
    }
    
    func getSet(setDocumentId: String) {
        Firestore.firestore().collection(FireConstants.section).document(setDocumentId).collection(FireConstants.set).addSnapshotListener { [self] (querySnap, error) in
            if let error = error {
                print("error getting set:", error.localizedDescription)
            } else if let snap = querySnap {
                sets.removeAll()
                for document in snap.documents {
                    let data = document.data()
                    let name = data[setInfo.name] as? String ?? ""
                    let documentId = document.documentID
                    sets.append(sectionSet(name: name, documentId: documentId))
                }
                tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segues.setToCards {
            guard let controller = segue.destination as? CardController,
                  let cards = sender as? [Card], let set = currentSet else { return }
            controller.sectionDocId = sectionDocumentId
            controller.setDocId = set.documentId
            controller.cards = cards
        }
    }
}

extension SetController: UITableViewDelegate, UITableViewDataSource, SetDelegate {
    
    func trashTapped(set: sectionSet) {
        delete(collection: setRef(sectionId: section.documentId).document(set.documentId).collection(FireConstants.card)) { [self] error in
            if let error = error {
                self.present(errorAlert(error: error), animated: true, completion: nil)
            } else {
                setRef(sectionId: section.documentId).document(set.documentId).delete { error in
                    if let error = error {
                        self.present(errorAlert(error: error), animated: true, completion: nil)
                    } 
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cells.setCell, for: indexPath) as? SetCell else { return UITableViewCell() }
        cell.fillCell(set: sets[indexPath.row], sectionUserCreaterId: section.createrId, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSet = sets[indexPath.row]
        var cards = [Card]()
        let cardRef = toSectionDocRef.collection(FireConstants.set).document(sets[indexPath.row].documentId).collection(FireConstants.card)
        let alertcontroller = UIAlertController(title: sets[indexPath.row].name, message: "select what you want for a set", preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: "Cards", style: .default, handler: { [self] (alert) in
            cardRef.addSnapshotListener { (querySnap, error) in
                if let error = error {
                    print("error getting cards:", error.localizedDescription)
                } else if let snap = querySnap {
                    cards.removeAll()
                    for document in snap.documents {
                        let data = document.data()
                        let definition = data[cardInfo.definition] as? String ?? ""
                        let term = data[cardInfo.term] as? String ?? ""
                        let passedInts = data["passed"] as? [Int] ?? [0,0]
                        var Booleans = [Bool]()
                        if passedInts.count == 3 {
                            Booleans = [true,true,true]
                            cards.append(Card(definition: definition, term: term, documentId: document.documentID, passed: Booleans))
                        } else {
                            if passedInts.count > 0 {
                                for int in passedInts {
                                    if int == 1 {
                                        Booleans.append(true)
                                    }
                                }
                                cards.append(Card(definition: definition, term: term, documentId: document.documentID, passed: Booleans))
                            } else {
                                cards.append(Card(definition: definition, term: term, documentId: document.documentID, passed: Booleans))
                            }
                        }
                    }
                    performSegue(withIdentifier: segues.setToCards, sender: cards)
                }
            }
        }))
        if section.createrId == Auth.auth().currentUser?.uid {
            alertcontroller.addAction(UIAlertAction(title: "Create Card", style: .default, handler: { [self] (alert) in
                guard !tableView.isEditing else {
                return
                }
                newCardViewHeight.constant = 250
            }))
        }
        alertcontroller.addAction(UIAlertAction(title: "schedule study time", style: .default, handler: { [self] (alert) in
            performSegue(withIdentifier: segues.ScheduleSegue, sender: sets[indexPath.row])
        }))
        alertcontroller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertcontroller, animated: true, completion: nil)
     }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(collection: toSectionDocRef.collection(FireConstants.set).document(sets[indexPath.row].documentId).collection(FireConstants.card)) { [self] (error) in
                if let error = error {
                    print("error deleting set", error.localizedDescription)
                } else {
                    toSectionDocRef.collection(FireConstants.set).document(sets[indexPath.row].documentId).delete { (eoor) in
                        if let error = eoor {
                            print("errpr deleting section:", error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    func delete(collection: CollectionReference, batchSize: Int = 100, completion: @escaping (Error?) -> ()) {
        collection.limit(to: batchSize).getDocuments { (docset, error) in
            guard let docset = docset, docset.count > 0 else {
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
