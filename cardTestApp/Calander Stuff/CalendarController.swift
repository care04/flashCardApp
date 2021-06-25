//
//  CalendarController.swift
//  cardTestApp
//
//  Created by Care Farrar on 5/12/21.
//
import FSCalendar
import UIKit

class CalendarController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {

    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var setNameLbl: UILabel!
    
    var set: sectionSet!
    var dates = [Date]()
    var titleName = "clothes  "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNameLbl.text = set.name
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.scrollDirection = .vertical
        calendarView.appearance.titleFont = UIFont.init(name: "American Typewriter", size: 20)
        calendarView.appearance.titleTodayColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dates.append(date)
        let alert = UIAlertController(title: "Event Alert Controller", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Add Item", style: .default, handler: { [self] (alert) in
            calendarView.cell(for: date, at: monthPosition)?.numberOfEvents += 1
            calendarView.deselect(date)
        }))
        alert.addAction(UIAlertAction(title: "Remove Item", style: .default, handler: { [self] (alert) in
            calendarView.cell(for: date, at: monthPosition)?.numberOfEvents -= 1
            calendarView.deselect(date)
        }))
        alert.addAction(UIAlertAction(title: "View Actions For Date", style: .default, handler: { (alert) in
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
