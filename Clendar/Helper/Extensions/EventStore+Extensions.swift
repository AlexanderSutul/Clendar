//
//  EventStore+Extensions.swift
//  Clendar
//
//  Created by Vinh Nguyen on 25/3/19.
//  Copyright © 2019 Vinh Nguyen. All rights reserved.
//

import EventKit
import Foundation

extension EKEventStore {
    // MARK: - CRUD

    /// Create an event
    /// - Parameters:
    ///   - title: event title
    ///   - startDate: event startDate
    ///   - endDate: event endDate
    ///   - calendar: event calendar
    ///   - span: event span
    ///   - completion: event completion handler that returns an event
    #if os(iOS) || os(macOS)
    func createEvent(
        title: String,
        startDate: Date,
        endDate: Date?,
        calendar: EKCalendar,
        span: EKSpan = .thisEvent,
        isAllDay: Bool = false,
        completion: ((Result<EKEvent, ClendarError>) -> Void)?
    ) {
        let event = EKEvent(eventStore: self)
        event.calendar = calendar
        event.title = title
        event.isAllDay = isAllDay
        event.startDate = startDate
        event.endDate = endDate

        do {
            try save(event, span: span, commit: true)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didCreateEvent, object: nil)
                completion?(.success(event))
            }
        } catch {
            DispatchQueue.main.async {
                completion?(.failure(ClendarError.mapFromError(error)))
            }
        }
    }
    #endif

    /// Delete event
    /// - Parameters:
    ///   - identifier: event identifier
    ///   - span: event span
    ///   - completion: event completion handler that returns an event
    #if os(iOS) || os(macOS)
    func deleteEvent(
        identifier: String,
        span: EKSpan = .thisEvent,
        completion: ((Result<Void, ClendarError>) -> Void)? = nil
    ) {
        guard let event = fetchEvent(identifier: identifier) else { return }

        do {
            try remove(event, span: span, commit: true)

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didDeleteEvent, object: nil)
                completion?(.success(()))
            }
        } catch {
            DispatchQueue.main.async {
                completion?(.failure(ClendarError.mapFromError(error)))
            }
        }
    }
    #endif

    // MARK: - Fetch

    /// Calendar for current AppName
    /// - Returns: App calendar
    /// - Parameter name: app name
    func calendarForApp(with name: String = AppInfo.appName) -> EKCalendar? {
        let calendars = self.calendars(for: .event)

        if let clendar = calendars.first(where: { $0.title == name }) {
            return clendar
        }
        else {
            #if os(iOS) || os(macOS)
            let newClendar = EKCalendar(for: .event, eventStore: self)
            newClendar.title = name
            newClendar.source = defaultCalendarForNewEvents?.source
            try? saveCalendar(newClendar, commit: true)
            return newClendar
            #else
            return nil
            #endif
        }
    }

    /// Fetch an EKEvent instance with given identifier
    /// - Parameter identifier: event identifier
    /// - Returns: an EKEvent instance with given identifier
    func fetchEvent(identifier: String) -> EKEvent? {
        event(withIdentifier: identifier)
    }
}
