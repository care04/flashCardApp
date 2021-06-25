//
//  FireStoreData.swift
//  cardTestApp
//
//  Created by Care Farrar on 5/10/21.
//
import UIKit
import FirebaseFirestore
import Foundation

struct Section {
    var name: String
    var documentId: String
    var createrId: String
}

struct sectionSet {
    var name: String
    var documentId: String
}

struct Card {
    var definition: String
    var term: String
    var documentId: String
    var passed: [Bool]
    func flipTableViewCell(cell: CardCell) -> CardCell {
        cell.textLabel?.numberOfLines = 0
        if cell.textLabel?.text == term {
            cell.textLabel?.text = definition
            return cell
        } else if cell.textLabel?.text == definition {
            cell.textLabel?.text = term
            return cell
        } else {
            return cell
        }
    }
}

enum User {
    static let userRef = "users"
    static let username = "username"
    static let userId = "userId"
}

func roundButtons(buttons: [UIButton]) {
    for button in buttons {
        button.layer.cornerRadius = 10
    }
}
