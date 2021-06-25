//
//  sectionViewController.swift
//  cardTestApp
//
//  Created by Care Farrar on 5/21/21.
//
import FirebaseFirestore
import UIKit

class sectionViewController: UIViewController {
    
    //MARK: Sections
    @IBOutlet weak var sectionsTable: UITableView!
    @IBOutlet weak var NewSectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var newSectionNameTextField: UITextField!
    
    //MARK: Variables
    var sections = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NewSectionViewHeightConstraint.constant = 0
        sectionsTable.dataSource = self
        sectionsTable.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sectionRef.addSnapshotListener { [self] (querySnap, error) in
            if let error = error {
                present(errorAlert(error: error), animated: true, completion: nil)
            }
            sections = parseSection(snapShot: querySnap)
        }
    }
    
    //MARK: Fucntions
    func add() {
        guard  NewSectionViewHeightConstraint.constant == 0 else {
            viewDissapear()
            return
        }
        NewSectionViewHeightConstraint.constant = 170
    }
    
    func viewDissapear() {
        newSectionNameTextField.text = ""
        NewSectionViewHeightConstraint.constant = 0
    }
    
    func saveSection () {
        guard newSectionNameTextField.text != "", let sectionName = newSectionNameTextField.text else { return }
        sectionRef.addDocument(data: [sectionInfo.name : sectionName]) { [self] (error) in
            if let error = error {
                present(errorAlert(error: error), animated: true, completion: nil)
            }
            viewDissapear()
        }
    }
    
    //MARK: IBAction
    @IBAction func AddClicked(_ sender: UIBarButtonItem) {
        add()
    }
    
    @IBAction func trashClicked(_ sender: UIBarButtonItem) {
        sectionsTable.isEditing = !sectionsTable.isEditing
    }
    
    @IBAction func saveSectionClicked(_ sender: UIButton) {
        saveSection()
    }
    
}
extension sectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifiers.sectionCell, for: indexPath)
        cell.textLabel?.text = sections[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let section = sections[indexPath.row]
            setRef(sectionId: section.documentId).addSnapshotListener { [self] (snap, error) in
                if let error = error {
                    present(errorAlert(error: error), animated: true, completion: nil)
                }
                for set in parseSet(snapShot: snap) {
                    deleteStuff(collection: cardRef(sectionId: section.documentId, setId: set.documentId)) { (error) in
                        if let error = error {
                            present(errorAlert(error: error), animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}
