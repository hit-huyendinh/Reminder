//
//  CalendarTabViewController.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 13/03/2022.
//

import UIKit
import FSCalendar

private struct Const {
    static let heightCell: CGFloat = 67.0
    static let heightHeader: CGFloat = 36.0
}

final class CalendarTabViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyView: UIView!
    @IBOutlet private weak var containerCalendarView: UIView!
    @IBOutlet private weak var calendar: FSCalendar!
    
    var viewModel: CalendarTaskViewModel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
        self.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset.top = containerCalendarView.frame.maxY - self.view.safeAreaInsets.top
    }
    
    // MARK: - Config
    private func config() {
        self.configCalendarView()
        self.configTableView()
    }
    
    private func configCalendarView() {
        self.calendar.appearance.caseOptions = [.weekdayUsesUpperCase]
        
        self.calendar.appearance.titleFont = Poppins.semiboldFont(size: 11)
        self.calendar.appearance.headerTitleFont = Poppins.mediumFont(size: 17)
        self.calendar.appearance.weekdayFont = Poppins.semiboldFont(size: 10)
        
        self.calendar.appearance.titleDefaultColor = UIColor(rgb: 0x323232)
        self.calendar.appearance.titleTodayColor = UIColor(rgb: 0x323232)
        self.calendar.appearance.titleSelectionColor = .white
        self.calendar.appearance.weekdayTextColor = UIColor(rgb: 0x535353)
        self.calendar.appearance.headerTitleColor = UIColor(rgb: 0x212121)
        
        self.calendar.appearance.selectionColor = UIColor(rgb: 0x008081).withAlphaComponent(0.7)
        self.calendar.appearance.todaySelectionColor = UIColor(rgb: 0x008081)
        self.calendar.appearance.todayColor = .clear
        self.calendar.appearance.eventSelectionColor = .white
                
        self.calendar.select(Date())
        
        let scopeGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        self.calendar.addGestureRecognizer(scopeGesture)
        
        self.calendar.delegate = self
        self.calendar.dataSource = self
        self.calendar.firstWeekday = 2
    }
    
    private func configTableView() {
        tableView.registerCell(type: CalendarTaskCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset.top = containerCalendarView.frame.maxY - 20
        tableView.contentInset.bottom = 20
    }
    
    // MARK: - Helper
    func bind(date: Date) {
        viewModel = CalendarTaskViewModel(date: date)
        if self.isViewLoaded {
            self.reloadData()
        }
    }
    
    func reloadData(isUpdateCalendar: Bool = true) {
        if isUpdateCalendar {
            calendar.select(viewModel.date)
        }
        
        tableView.reloadData()
        if viewModel.numberOfSections() == 0 {
            tableView.isHidden = true
            emptyView.isHidden = false
        } else {
            tableView.isHidden = false
            emptyView.isHidden = true
        }
    }
}

// MARK: - FSCalendarDataSource
extension CalendarTabViewController: FSCalendarDataSource {
    func fsCalendar(_ calendar: FSCalendar, eventColorsAt date: Date) -> [UIColor] {
        let colors = viewModel.colorsAt(date: date)
        return colors.count == 0 ? [.clear] : colors
    }
    
    func fsCalendar(_ calendar: FSCalendar, selectedEventColorsAt date: Date) -> [UIColor] {
        let colors = viewModel.colorsAt(date: date)
        return colors.count == 0 ? [.clear] : colors
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return viewModel.colorsAt(date: date).count
    }
}

// MARK: - FSCalendarDelegate
extension CalendarTabViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.viewModel.date = date.tomorrow
        self.reloadData(isUpdateCalendar: false)
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.heightConstraint()?.constant = bounds.height
        self.view.layoutIfNeeded()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CalendarTabViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: CalendarTaskCell.self, indexPath: indexPath)!
        cell.bind(viewModel: viewModel.item(at: indexPath.row, section: indexPath.section))
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let date = viewModel.dateFor(section: section)
        let backgroundView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.font = Nunito.extraboldFont(size: 15)
        
        
        let subtitleLabel = UILabel()
        subtitleLabel.font = Nunito.regularFont(size: 15)
        if date.isInToday {
            subtitleLabel.textColor = UIColor(rgb: 0x008081)
            titleLabel.textColor = UIColor(rgb: 0x008081)
            backgroundView.backgroundColor = UIColor(rgb: 0xDAF2F2)
        } else {
            subtitleLabel.textColor = UIColor(rgb: 0x212121)
            titleLabel.textColor = UIColor(rgb: 0x212121)
            backgroundView.backgroundColor = UIColor(rgb: 0xECECEC)
        }
        
        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(subtitleLabel)
        
        titleLabel.text = date.weekDayFullString.uppercased()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        subtitleLabel.text = formatter.string(from: date)
        
        titleLabel.sizeToFit()
        subtitleLabel.sizeToFit()
        
        titleLabel.frame.origin.x = 20
        titleLabel.frame.origin.y = (Const.heightHeader - titleLabel.frame.height) / 2
        subtitleLabel.frame.origin.x = titleLabel.frame.maxX + 4
        subtitleLabel.frame.origin.y = (Const.heightHeader - subtitleLabel.frame.height) / 2
        return backgroundView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Const.heightCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Const.heightHeader
    }
}
