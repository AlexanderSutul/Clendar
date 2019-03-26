//
//  CalendarViewController.swift
//  Clendar
//
//  Created by Vinh Nguyen on 23/3/19.
//  Copyright © 2019 Vinh Nguyen. All rights reserved.
//

import CVCalendar
import Foundation

final class CalendarViewController: BaseViewController {

    // MARK: - View Model

    private lazy var inputParser = InputParser()
    private lazy var workItem = WorkItem()
    private lazy var eventHandler = EventHandler()
    internal var currentInput: InputParser.InputParserResult?

    // MARK: - Properties
    
    @IBOutlet var calendarView: CVCalendarView! {
        didSet {
            self.calendarView.calendarAppearanceDelegate = self
            self.calendarView.animatorDelegate = self
            self.calendarView.calendarDelegate = self
        }
    }

    @IBOutlet var dayView: CVCalendarMenuView! {
        didSet {
            self.dayView.delegate = self
        }
    }

    @IBOutlet private var inputTextField: TextField? {
        didSet {
            self.inputTextField?.delegate = self
        }
    }

    @IBOutlet private var todayButton: Button!
    @IBOutlet private var modeButton: Button! {
        didSet {
            self.modeButton?.setTitle("MONTH", for: .normal)
            self.modeButton?.setTitle("WEEK", for: .selected)
        }
    }
    @IBOutlet var monthLabel: UILabel! {
        didSet {
            self.monthLabel.font = FontConfig.mediumFontWithSize(30)
            self.monthLabel.text = CVDate(date: Date(), calendar: self.currentCalendar).globalDescription.uppercased()
        }
    }

    private var calendarMode: CalendarMode = .monthView
    private var selectedDay: DayView?
    private lazy var currentCalendar: Calendar = {
        var proxy = Calendar(identifier: .gregorian)
        proxy.locale = Locale(identifier: "en_US_POSIX")
        return proxy
    }()

    // MARK: - Life cycle

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.calendarView.commitCalendarViewUpdate()
        self.dayView.commitMenuViewUpdate()
    }

    // MARK: - Parse

    private func throttleParseInput(_ input: String) {
        self.workItem.perform(after: 1.0) { [weak self] in
            self?.currentInput = self?.inputParser.parse(input)
        }
    }

    private func handleInput(textField: UITextField) {
        guard let result = self.currentInput else { return }
        self.eventHandler.createEvent(result.action, startDate: result.startDate, endDate: result.endDate) { [weak self] in
            self?.calendarView.toggleViewWithDate(result.startDate)

            textField.isUserInteractionEnabled = false
            textField.text = "Event created in Calendar!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                textField.text = ""
                textField.isUserInteractionEnabled = true
            }
        }
    }
}

extension CalendarViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {

    // MARK: - CVCalendarViewDelegate, CVCalendarMenuViewDelegate

    func presentationMode() -> CalendarMode { return self.calendarMode }

    func firstWeekday() -> Weekday { return .sunday }

    func calendar() -> Calendar? { return self.currentCalendar }

    func dayOfWeekTextColor(by weekday: Weekday) -> UIColor {
        return weekday == .sunday ? .red : .black
    }

    func shouldShowWeekdaysOut() -> Bool { return true }

    func shouldAutoSelectDayOnMonthChange() -> Bool { return false }

    func didSelectDayView(_ dayView: CVCalendarDayView, animationDidFinish: Bool) {
        self.selectedDay = dayView
    }

    func presentedDateUpdated(_ date: CVDate) {
        self.monthLabel.text = date.globalDescription
    }

    func weekdaySymbolType() -> WeekdaySymbolType { return .short }

    func dayOfWeekTextColor() -> UIColor { return .black }

    func dayOfWeekBackGroundColor() -> UIColor { return .white }

    func shouldAnimateResizing() -> Bool { return true }

    func shouldShowCustomSingleSelection() -> Bool { return true }

    func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
        let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.frame, shape: CVShape.circle)
        circleView.fillColor = .colorFromCode(0xCCCCCC)
        return circleView
    }

    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        return dayView.isCurrentDay
    }
}

extension CalendarViewController: CVCalendarViewAppearanceDelegate {

    // MARK: - CVCalendarViewAppearanceDelegate

    func dayLabelWeekdayDisabledColor() -> UIColor { return .lightGray }

    func dayLabelPresentWeekdayInitallyBold() -> Bool { return false }

    func spaceBetweenDayViews() -> CGFloat { return 0 }

    func dayLabelFont(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIFont {
        return FontConfig.regularFontWithSize(15)
    }

    func dayLabelColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status, present) {
        case (_, .selected, _), (_, .highlighted, _): return CalendarColorsConfig.selectedText
        case (.sunday, .in, _): return CalendarColorsConfig.sundayText
        case (.sunday, _, _): return CalendarColorsConfig.sundayTextDisabled
        case (_, .in, _): return CalendarColorsConfig.text
        default: return CalendarColorsConfig.textDisabled
        }
    }

    func dayLabelBackgroundColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status, present) {
        case (.sunday, .selected, _), (.sunday, .highlighted, _): return CalendarColorsConfig.sundaySelectionBackground
        case (_, .selected, _), (_, .highlighted, _): return CalendarColorsConfig.selectionBackground
        default: return nil
        }
    }
}

extension CalendarViewController {

    // MARK: - Actions

    @IBAction private func didTapModeButton(sender: UIButton) {
        sender.isSelected.toggle()
        self.calendarMode = sender.isSelected ? .weekView : .monthView
        self.calendarView.changeMode(self.calendarMode)
    }

    @IBAction func todayMonthView() {
        self.calendarView.toggleCurrentDayView()
    }

    @IBAction func loadPrevious() {
        self.calendarView.loadPreviousView()
    }

    @IBAction func loadNext() {
        self.calendarView.loadNextView()
    }
}

extension CalendarViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let substring = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        self.throttleParseInput(substring)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        defer {
            textField.resignFirstResponder()
        }

        self.handleInput(textField: textField)
        return true
    }
}
