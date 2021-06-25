//
//  CalandarConsants.swift
//  cardTestApp
//
//  Created by Care Farrar on 5/14/21.
//

import Foundation

class Events {
    static let eventRef = Events()
    var events = [Event]()
}

struct Event {
    var name: String
    var date: Date
}
