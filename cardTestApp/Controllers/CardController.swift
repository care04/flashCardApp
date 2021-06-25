//
//  CardController.swift
//  cardTestApp
//
//  Created by Care Farrar on 5/10/21.
//
import FirebaseFirestore
import UIKit

class CardController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var cards = [Card]()
    var cardsForTable = [Card]()
    var sectionDocId: String!
    var setDocId: String!
    enum cardType {
        case All, notPassed, passed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        tableView.isUserInteractionEnabled = false
    }
    
    @IBAction func CardTypeSelect(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select Card Set", message: "Select the type of cards you would like to study", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Not Passed Cards", style: .default, handler: { [self] (alert) in
            hide()
            cardsForTable = CardsToAdd(type: .notPassed, cardsTo: cards)
            tableViewStuff(string: "not passed cards")
        }))
        alert.addAction(UIAlertAction(title: "Passed Cards", style: .default, handler: { [self] (alert) in
            hide()
            cardsForTable = CardsToAdd(type: .passed, cardsTo: cards)
            tableViewStuff(string: "passed cards")
        }))
        alert.addAction(UIAlertAction(title: "All Cards", style: .default, handler: { [self] (alert) in
            hide()
            cardsForTable = CardsToAdd(type: .All, cardsTo: cards)
            tableViewStuff(string: "Cards")
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func tableViewStuff(string: String) {
        if cardsForTable.count > 0 {
            tableView.isHidden = false
            tableView.isUserInteractionEnabled = true
            tableView.delegate = self
            tableView.dataSource = self
            tableView.reloadData()
            currentCards.ref.cards = cardsForTable
        } else {
            let alert = UIAlertController(title: "No Cards In \(string)", message: "Please select a different card selection", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func CardsToAdd(type: cardType, cardsTo: [Card]) -> [Card] {
        var cardsToReturn = [Card]()
        if type == .All {
            return cardsTo
        } else if type == .notPassed {
            for card in cardsTo {
                if card.passed.count < 3 {
                    cardsToReturn.append(card)
                }
            }
        } else {
            for card in cardsTo {
                if card.passed.count == 3 {
                    cardsToReturn.append(card)
                }
            }
        }
        return cardsToReturn
    }
    func hide() {
        tableView.isHidden = true
        tableView.isUserInteractionEnabled = false
    }
    @IBAction func FinishSet(_ sender: UIBarButtonItem) {
        for card in cardsForTable {
            Firestore.firestore().collection(FireConstants.section).document(sectionDocId).collection(FireConstants.set).document(setDocId).collection(FireConstants.card).document(card.documentId).updateData([cardInfo.passed : card.passed])
        }
        navigationController?.dismiss(animated: true, completion: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        selectCard.card.answer = ""
    }
}

extension CardController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cells.cardCell, for: indexPath) as? CardCell else { return UITableViewCell() }
        cell.fillCell(givenCard: cardsForTable[indexPath.row], givenIndexPath: indexPath, givenTable: tableView)
        return cell
    }
}
