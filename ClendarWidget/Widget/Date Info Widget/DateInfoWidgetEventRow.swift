//
//  WidgetEventRow.swift
//  ClendarWidgetExtension
//
//  Created by Vinh Nguyen on 10/31/20.
//  Copyright © 2020 Vinh Nguyen. All rights reserved.
//

import Foundation
import SwiftUI

struct WidgetEventRow: View {
	var id = UUID()
	let event: Event

	var body: some View {
		HStack(spacing: 5) {
			WidgetEventColorBar(event: event)
			WidgetEventRowLabel(event: event)
		}
	}
}

struct WidgetEventRowLabel: View {
	let event: Event

	var body: some View {
		let message = event.event?.title ?? "-"
		let title = event.event?.durationText(startDateOnly: true) ?? "-"
		let titleAndMessage = "[\(title)] \(message)"
		Text(titleAndMessage)
			.font(.semiboldFontWithSize(12))
			.foregroundColor(Color(.gray))
			.lineLimit(2)
	}
}

struct WidgetEventColorBar: View {
	let event: Event

	var body: some View {
		RoundedRectangle(cornerRadius: 5, style: .continuous)
			.fill(Color(event.event?.calendar.cgColor ?? CGColor(gray: 1, alpha: 1)))
			.frame(width: 5, height: 20)
	}
}

extension Date {
	var hourString: String {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
		return dateFormatter.string(from: self)
	}
}
