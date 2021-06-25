//
//  CardCell.swift
//  cardTestApp
//
//  Created by Care Farrar on 5/12/21.
//

import UIKit

class CardCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var answerText: UITextView!
    @IBOutlet weak var checkAnswerButton: UIButton!
    @IBOutlet weak var termText: UILabel!
    @IBOutlet weak var definitionLabel: UILabel!
    
    var card: Card?
    var indexPath: IndexPath!
    var table: UITableView?
    
    override func awakeFromNib() {
        answerText.delegate = self
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        definitionLabel.text = ""
    }
    
    func fillCell(givenCard: Card, givenIndexPath: IndexPath, givenTable: UITableView) {
        if selectCard.card.answer != "" {
            let answerString = givenCard.definition.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let myanswer = selectCard.card.answer
            let givenString = myanswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if answerString == givenString {
                definitionLabel.text = "Passed"
                answerText.isEditable = false
                if givenCard.passed.count < 3 {
                    var index = 0
                    for card in currentCards.ref.cards {
                        if card.documentId == givenCard.documentId {
                            currentCards.ref.cards[index].passed.append(true)
                            print(currentCards.ref.cards[index].passed)
                            break
                        }
                        index += 1
                    }
                }
            } else {
                definitionLabel.text = "Your answer: \(myanswer)\n\n" + "The Actual Answer: \(givenCard.definition)"
            }
        }
        termText.text = givenCard.term.capitalized
        card = givenCard
        indexPath = givenIndexPath
        table = givenTable
        
    }
    
    @IBAction func checkAnswerClicked(_ sender: Any) {
        if answerText.text != "" {
            selectCard.card.answer = answerText.text
            table?.reloadRows(at: [indexPath], with: .automatic)
            answerText.text = ""
        }
    }
}
