//
//  CreateEventViewController.swift
//  Clendar
//
//  Created by Vinh Nguyen on 10/27/20.
//  Copyright © 2020 Vinh Nguyen. All rights reserved.
//

import UIKit
import EasyClosure
import EventKit

// NOTE: using EventKitUI's native controller to simplify for now

// TODO: check bug when create "hello" event (start date should not == end date) => create duration settings

enum CreateEventType {
    case create
    case edit
}

struct CreateEventViewModel {
    public private(set) var event: Event?
    var text: String = ""
    var startDate: Date = Date()
    var endDate: Date?

    init(event: Event? = nil) {
        self.event = event
        guard let event = event?.event else { return }
        text = event.title
        startDate = event.startDate
        endDate = event.endDate
    }
}

internal struct EventOverride {
    let text: String
    let startDate: Date
    let endDate: Date?
}

class CreateEventViewController: BaseViewController {

    // MARK: - Callback

    var didUpdateEvent: ((EKEvent) -> Void)?

    // MARK: - Properties

    private lazy var workItem = WorkItem()

    var createEventType: CreateEventType = .create

    var viewModel = CreateEventViewModel()

    @IBOutlet private var deleteButton: Button! {
        didSet {
            deleteButton.tintColor = .buttonTintColor
            deleteButton.backgroundColor = .detructiveColor
        }
    }

    @IBOutlet private var startDateStackContainerView: UIView!

    @IBOutlet private var endDateStackContainerView: UIView!

    @IBOutlet private var startDatePicker: UIDatePicker! {
        didSet {
            startDatePicker.configurePreferredDatePickerStyle()
        }
    }

    @IBOutlet private var endDatePicker: UIDatePicker! {
        didSet {
            endDatePicker.configurePreferredDatePickerStyle()
        }
    }

    @IBOutlet private var closeButton: UIButton! {
        didSet {
            closeButton.tintColor = .primaryColor
            closeButton.on.tap { [weak self] in
                guard let self = self else { return }
                self.dismiss(animated: true)
            }
        }
    }

    @IBOutlet private var saveButton: UIButton! {
        didSet {
            saveButton.tintColor = .primaryColor
            saveButton.on.tap { [weak self] in
                guard let self = self else { return }
                self.createNewEvent()
            }
        }
    }

    @IBOutlet private var scrollView: UIScrollView! {
        didSet {
            scrollView.backgroundColor = .backgroundColor
        }
    }

    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text = createEventType == .create ? "New Event" : "Edit Event"
            titleLabel.numberOfLines = 0
            titleLabel.textColor = .appDark
            titleLabel.font = .boldFontWithSize(30)
        }
    }

    @IBOutlet private var inputTextField: TextField! {
        didSet {
            inputTextField.delegate = self
            inputTextField.placeholder = "Write something on Friday at 5PM"
        }
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .backgroundColor

        deleteButton.isHidden = createEventType == .create

        bind(viewModel)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputTextField.becomeFirstResponder()
    }

    // MARK: - Private

    private func createNewEvent(_ override: EventOverride? = nil) {
        guard let input = inputTextField.text else { return dismiss() }
        guard input.isEmpty == false else { return dismiss() }
        guard let result = NaturalInputParser().parse(input) else { return }

        let override = EventOverride(
            text: result.action,
            startDate: startDatePicker.date,
            endDate: endDatePicker.date
        )

        EventKitWrapper.shared.createEvent(override.text, startDate: override.startDate, endDate: override.endDate) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let event):
                self.inputTextField.text = ""
                self.didUpdateEvent?(event)
                self.dismiss()

            case .failure(let error): AlertManager.showWithError(error)

            }
        }
    }

    private func dismiss() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    private func parseDate(_ substring: String) {
        guard substring.isEmpty == false else { return }

        workItem.perform { [weak self] in
            guard let self = self else { return }
            guard let result = NaturalInputParser().parse(substring) else { return }
            self.startDatePicker.date = result.startDate

            if let endDate = result.endDate {
                self.endDatePicker.date = endDate
            }
        }
    }

    private func bind(_ viewModel: CreateEventViewModel) {
        inputTextField.text = viewModel.text

        startDatePicker.date = viewModel.startDate

        if let endDate = viewModel.endDate {
            endDatePicker.date = endDate
        }
    }

    // MARK: - Action

    @IBAction private func deleteEvent() {
        dismissKeyboard()

        guard let event = viewModel.event else { return }
        guard let eventID = event.id else { return }

        AlertManager.showActionSheet(message: "Are you sure you want to delete this event?", showDelete: true, deleteAction: {
            EventKitWrapper.shared.deleteEvent(identifier: eventID) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success: self.dismiss()
                case .failure(let error): AlertManager.showWithError(error)
                }
            }
        })
    }

}

extension CreateEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let substring = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        parseDate(substring)
        return true
    }
}
