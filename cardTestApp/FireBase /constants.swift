//
//  constants.swift
//  cardTestApp
//
//  Created by Care Farrar on 5/21/21.
//
import FirebaseFirestore
import Foundation

var sectionRef: CollectionReference = Firestore.firestore().collection(FireConstants.section)

func setRef(sectionId: String) -> CollectionReference {
    return sectionRef.document(sectionId).collection(FireConstants.set)
}

func cardRef(sectionId: String, setId: String) -> CollectionReference {
    setRef(sectionId: sectionId).document(setId).collection(FireConstants.card)
}

func errorAlert(error: Error) -> UIAlertController {
    let controller = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
    controller.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
    return controller
}

func parseSection(snapShot: QuerySnapshot?) -> [Section] {
    var sections = [Section]()
    guard let snap = snapShot else { return sections }
    sections.removeAll()
    for document in snap.documents {
        let data = document.data()
        let sectionName = data[sectionInfo.name] as? String ?? ""
        let documentId = document.documentID
        let userCreateID = data[sectionInfo.sectionCreateruid] as? String ?? ""
        sections.append(Section(name: sectionName, documentId: documentId, createrId: userCreateID))
    }
    return sections
}

func parseSet(snapShot: QuerySnapshot?) -> [sectionSet] {
    var sets = [sectionSet]()
    guard let snap = snapShot else { return sets }
        sets.removeAll()
        for document in snap.documents {
            let data = document.data()
            let name = data[setInfo.name] as? String ?? ""
            let documentId = document.documentID
            sets.append(sectionSet(name: name, documentId: documentId))
        }
    return sets
}

func parseCard(snapShot: QuerySnapshot?) -> [Card] {
    var cards = [Card]()
    guard let snap = snapShot else { return cards }
    cards.removeAll()
    for document in snap.documents {
        let data = document.data()
        let definition = data[cardInfo.definition] as? String ?? ""
        let term = data[cardInfo.term] as? String ?? ""
        let passedInts = data[cardInfo.passed] as? [Int] ?? [Int]()
        var passedBools: [Bool] = [Bool]()
        for passed in passedInts {
            if passed == 1 {
                passedBools.append(true)
            }
        }
        if passedBools.count < 3 {
            cards.append(Card(definition: definition, term: term, documentId: document.documentID, passed: passedBools))
        } else if passedBools.count == 3 {
            cards.append(Card(definition: definition, term: term, documentId: document.documentID, passed: passedBools))
        }
        return cards
    }
    return cards
}

    func deleteStuff(collection: CollectionReference, batchSize: Int = 100, completion: @escaping (Error?) -> ()) {
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
            batch.commit { (batchError) in
                if let batchError = batchError {
                    completion(batchError)
                } else {
                    deleteStuff(collection: collection, batchSize: batchSize, completion: completion)
                }
            }
        }
    }

