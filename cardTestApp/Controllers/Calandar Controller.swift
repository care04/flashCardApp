//
//  Calandar Controller.swift
//  cardTestApp
//
//  Created by Care Farrar on 6/25/21.
//
import Firebase
import FSCalendar
import UIKit
import UserNotifications

class Calandar_Controller: UIViewController {

    var setToStudy: sectionSet! = sectionSet(name: "", documentId: "")
    var date: Date?
    let center = UNUserNotificationCenter.current()
    
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
                functionNotifications(date: date)
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
    func functionNotifications(date: Date) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [self] granted, error in
            if let error = error {
                self.present(errorAlert(error: error), animated: true, completion: nil)
            } else {
                center.getNotificationSettings { (settings) in
                    guard settings.authorizationStatus == .authorized ||
                          settings.authorizationStatus == .provisional else { return }
                    if settings.alertSetting == .enabled {
                        //notification content
                        let content = UNMutableNotificationContent()
                        content.title = "Study Time"
                        content.body = "Its time to review \(self.setToStudy.name)"
                        //trigger
                        let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
                        //request
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                        // add notification
                        center.add(request) { error in
                            if let error = error {
                                self.present(errorAlert(error: error), animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
}
