//
//  SetCell.swift
//  cardTestApp
//
//  Created by Care Farrar on 6/4/21.
//
import FirebaseAuth
import FirebaseFirestore
import UIKit

protocol SetDelegate {
    func trashTapped(set: sectionSet)
}

class SetCell: UITableViewCell {

    @IBOutlet weak var trashPic: UIImageView!
    @IBOutlet weak var setName: UILabel!
    
    private var currentSet: sectionSet!
    private var delegate: SetDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(trashTapped))
        trashPic.addGestureRecognizer(tap)
    }
    
    @objc func trashTapped() {
        delegate?.trashTapped(set: currentSet)
    }
    
    func fillCell(set: sectionSet,sectionUserCreaterId: String,delegate: SetDelegate) {
        currentSet = set
        self.delegate = delegate
        setName.text = set.name
        if let user = Auth.auth().currentUser {
            if user.uid == sectionUserCreaterId {
                trashPic.isHidden = false
                trashPic.isUserInteractionEnabled = true
            } else {
                trashPic.isHidden = true
                trashPic.isUserInteractionEnabled = false
            }
        }
    }
}
