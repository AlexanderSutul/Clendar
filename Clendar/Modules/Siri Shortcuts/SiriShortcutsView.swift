//
//  SiriShortcutsView.swift
//  Clendar
//
//  Created by Vinh Nguyen on 30/01/2021.
//  Copyright © 2021 Vinh Nguyen. All rights reserved.
//

import SwiftUI

struct SiriShortcutsView: View {
    var body: some View {
        VStack(spacing: 50) {

            Text(R.string.localizable.siriShortcuts())
                .font(.boldFontWithSize(20))
                .gradientForeground(colors: [.red, .blue])

            ScrollView {
                VStack(spacing: 50) {
                    Text("You can now quick shortcuts to Siri and Shortcuts app. Try adding one below")
                        .font(.mediumFontWithSize(15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    VStack(spacing: 20) {
                        Text(R.string.localizable.createNewClendarEventS())
                        SiriButton(shortcut: ShortcutBuilder.addEventShortcut).frame(height: 30)
                    }

                    VStack(spacing: 20) {
                        Text(R.string.localizable.openSettings())
                        SiriButton(shortcut: ShortcutBuilder.openSettingsShortcut).frame(height: 30)
                    }

                    VStack(spacing: 20) {
                        Text(R.string.localizable.showSiriShortcutsView())
                        SiriButton(shortcut: ShortcutBuilder.openSiriShortcut).frame(height: 30)
                    }
                }
            }

            Text("Swipe down to dismiss")
                .font(.mediumFontWithSize(13))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

        }
        .padding()
    }
}
