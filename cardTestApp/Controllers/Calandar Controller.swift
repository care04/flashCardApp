//
//  Calandar Controller.swift
//  cardTestApp
//
//  Created by Care Farrar on 6/25/21.
//
import Firebase
import FSCalendar
import UIKit

class Calandar_Controller: UIViewController {

    var setToStudy: sectionSet! = sectionSet(name: "", documentId: "")
    var date: Date?
    
    @IBOutlet weak var StudySet: UILabel!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var studyDate: UILabel!
    @IBOutlet weak var scheduleTimeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard setToStudy.name != "" else { return }
        StudySet.text = setToStudy.name
        calendar.delegate = self
        roundButtons(buttons: [scheduleTimeBtn])
    }
    
    @IBAction func SaveTimeClicked(_ sender: UIButton) {
        guard let date = date else { return }
        Firestore.firestore().collection(FireConstants.schedule).addDocument(data: [scheduleInfo.set : setToStudy.name,  scheduleInfo.date : date, scheduleInfo.docId : setToStudy.documentId]) { [self] (error) in
            if let error = error {
                present(errorAlert(error: error), animated: true, completion: nil)
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
}

extension Calandar_Controller: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM-dd-yyyy"
        self.date = date
        studyDate.text = dateFormatter.string(from: date)
    }
}
