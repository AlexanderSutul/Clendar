//
//  DateParser.swift
//  Clendar
//
//  Created by Vinh Nguyen on 24/3/19.
//  Copyright © 2019 Vinh Nguyen. All rights reserved.
//

import Foundation
import SwiftyChrono
import SwiftDate

enum CalendarTypeSegment {
    case lunar
    case solar
}

final class NaturalInputParser {

    // MARK: - Model

    struct InputParserResult {
        var action: String
        var startDate: Date
        var endDate: Date?
    }

    private lazy var chrono = Chrono()

    init() {
        Chrono.preferredLanguage = .english
        Chrono.defaultImpliedHour = 9
    }

    // MARK: - Public

    func parse(_ input: String, type: CalendarTypeSegment = .solar) -> InputParserResult? {
        guard input.isEmpty == false else { return nil }
        let results = chrono.parse(text: input)
        let process = results.process(with: input)
        let startDate = process.startDate
        let endDate = process.endDate

        switch type {
        case .lunar:
            let gregorianStartDate = startDate.toGregorianDate
            let gregorianEndDate = endDate?.toGregorianDate
            return InputParserResult(action: process.action,
                                     startDate: gregorianStartDate,
                                     endDate: gregorianEndDate)

        case .solar:
            return InputParserResult(action: process.action,
                                     startDate: startDate,
                                     endDate: endDate)
        }
    }
}
