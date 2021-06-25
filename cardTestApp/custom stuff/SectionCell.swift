//
//  SectionCell.swift
//  cardTestApp
//
//  Created by Care Farrar on 6/4/21.
//
import FirebaseAuth
import FirebaseFirestore
import UIKit

protocol SectionDelegate {
    func trashTapped(section: Section)
}

class SectionCell: UITableViewCell {
    @IBOutlet weak var deleteSection: UIImageView!
    @IBOutlet weak var sectionName: UILabel!
    
    private var currentSection: Section!
    private var delegate: SectionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(trashTapped))
        deleteSection.addGestureRecognizer(tap)
    }
    
    @objc func trashTapped() {
        delegate?.trashTapped(section: currentSection)
    }
    
    func fillCell(section: Section, delegate: SectionDelegate) {
        currentSection = section
        self.delegate = delegate
        sectionName.text = section.name
        if let user = Auth.auth().currentUser {
            if user.uid == section.createrId {
                deleteSection.isHidden = false
                deleteSection.isUserInteractionEnabled = true
            } else {
                deleteSection.isHidden = true
                deleteSection.isUserInteractionEnabled = false
            }
        }
    }

}
