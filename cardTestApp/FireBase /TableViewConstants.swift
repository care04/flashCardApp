//
//  TableViewConstants.swift
//  cardTestApp
//
//  Created by Care Farrar on 5/21/21.
//

import Foundation

enum cellIdentifiers {
    static let sectionCell = "sectionCell"
}

struct TestSection {
    var name: String
    var documentId: String
    var sets: [testSet]
}

struct testSet {
    var name: String
    var documentId: String
    var cards: [Card]
}
