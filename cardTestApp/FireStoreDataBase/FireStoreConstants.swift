//
//  FireStoreConstants.swift
//  cardTestApp
//
//  Created by Care Farrar on 5/10/21.
//

import Foundation

enum FireConstants {
    static let section = "Sections"
    static let set = "Sets"
    static let card = "FlashCards"
}

enum sectionInfo {
    static let name = "SectionName"
    static let sectionCreateruid = "sectionCreateruid"
}

enum setInfo {
    static let name = "SetName"
}

enum cardInfo {
    static let definition = "CardDefinition"
    static let term = "CardTerm"
    static let passed = "passed"
}
