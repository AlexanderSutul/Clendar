//
//  QuickEventWrapperView.swift
//  Clendar
//
//  Created by Vĩnh Nguyễn on 11/19/20.
//  Copyright © 2020 Vinh Nguyen. All rights reserved.
//

import EventKit
import SwiftUI
import Shift

internal struct EventOverride {
    let text: String
    let startDate: Date
    let endDate: Date?
    let isAllDay: Bool
}

internal class QuickEventStore: ObservableObject {
    @Published var query = ""
}

struct QuickEventView: View {
    @EnvironmentObject var store: SharedStore
    @StateObject private var quickEventStore = QuickEventStore()
    @State private var parsedText = ""
    @State private var startTime = Date()
    @State private var endTime = Date().offsetWithDefaultDuration
    @State private var isAllDay = false
    @Binding var showCreateEventState: Bool

    var body: some View {
        VStack {
            HStack {
                Button(
                    action: {
                        genLightHaptic()
                        showCreateEventState = false
                    },
                    label: {
                        Image(systemName: "chevron.down")
                            .font(.boldFontWithSize(20))
                    }
                )
                .accentColor(.appRed)
                .keyboardShortcut(.escape)
                .help("Collapse this view")

                Spacer()
                Text("New Event")
                    .font(.semiboldFontWithSize(15))
                Spacer()

                Button(
                    action: {
                        createNewEvent()
                    },
                    label: {
                        Image(systemName: "calendar.badge.plus")
                            .font(.boldFontWithSize(20))
                    }
                )
                .accentColor(.appRed)
                .disabled(quickEventStore.query.isEmpty)
                .keyboardShortcut("s", modifiers: [.command])
                .help("Create new event")
            }

            Divider()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    Spacer()
                    TextField(
                        R.string.localizable.readABookThisFriday8PM(),
                        text: $quickEventStore.query,
                        onCommit: {
                            self.parse(quickEventStore.query)
                        }
                    )
                    .accessibility(label: Text("Input event"))
                    .font(.regularFontWithSize(18))
                    .foregroundColor(.appDark)
                    .submitLabel(.done)

                    Toggle("All day", isOn: $isAllDay)
                        .keyboardShortcut(.tab)
                        .font(.mediumFontWithSize(15))
                        .toggleStyle(SwitchToggleStyle(tint: .appRed))
                        .fixedSize()

                    if !isAllDay {
                        Divider()

                        VStack {
                            Text("Start time")
                                .font(.semiboldFontWithSize(15))
                            DatePicker("Start time", selection: $startTime)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .font(.mediumFontWithSize(15))
                                .accessibility(label: Text("Select event start time"))
                        }

                        Divider()

                        VStack {
                            Text("End time")
                                .font(.semiboldFontWithSize(15))
                            DatePicker("End time", selection: $endTime)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .font(.mediumFontWithSize(15))
                                .accessibility(label: Text("Select event end time"))
                        }
                    }
                }
                .padding(.bottom, 300)
            }
        }
        .onReceive(quickEventStore.$query) { output in
            self.parse(output)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .preferredColorScheme(appColorScheme)
        .environment(\.colorScheme, appColorScheme)
        .background(store.appBackgroundColor.edgesIgnoringSafeArea(.all))
    }
}

extension QuickEventView {
    // MARK: - Private

    @discardableResult
    private func parse(_ text: String) -> Bool {
        guard text.isEmpty == false else { return false }
        guard let result = NaturalInputParser().parse(text) else { return false }
        parsedText = result.parsedText
        startTime = result.startDate
        endTime = result.endDate ?? result.startDate.offsetWithDefaultDuration
        return true
    }

    private func createNewEvent(_: EventOverride? = nil) {
        guard quickEventStore.query.isEmpty == false else { return }

        Task {
            do {
                let createdEvent = try await Shift.shared.createEvent(parsedText, startDate: startTime, endDate: endTime, isAllDay: isAllDay)
                genSuccessHaptic()
                self.showCreateEventState = false
                self.store.selectedDate = createdEvent.startDate
            } catch {
                genErrorHaptic()
                AlertManager.showWithError(error)
            }
        }
    }
}
