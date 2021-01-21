//
//  ClendarApp.swift
//  Clendar
//
//  Created by Vinh Nguyen on 18/11/2020.
//  Copyright © 2020 Vinh Nguyen. All rights reserved.
//

import SwiftDate
import SwiftUI
import Shift

// swiftlint:disable:next private_over_fileprivate
fileprivate var shortcutItemToProcess: UIApplicationShortcutItem? {
    didSet {
        guard let name = shortcutItemToProcess?.userInfo?[Constants.addEventQuickActionKey] as? String else { return }

        switch name {
        case Constants.addEventQuickActionID:
            NotificationCenter.default.post(name: .addEventShortcutAction, object: nil)

        default:
            break
        }
    }
}

@main
struct ClendarApp: App {

    // swiftlint:disable:next weak_delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @Environment(\.scenePhase) var phase

    let store = Store()

    init() {
        configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(store)
        }
        .onChange(of: phase) { (newPhase) in
            switch newPhase {
            case .background: addQuickActions()
            case .active, .inactive: break
            @unknown default: break
            }
        }
    }

    /**
     During the transition to a background state is a good time to update any dynamic quick actions because this code is always executed before the user returns to the Home screen.
     */
    func addQuickActions() {
        var userInfo: [String: NSSecureCoding] {
            [Constants.addEventQuickActionKey : Constants.addEventQuickActionID as NSSecureCoding]
        }

        UIApplication.shared.shortcutItems = [
            UIApplicationShortcutItem(
                type: Constants.addEventQuickActionID,
                localizedTitle: NSLocalizedString("New Event", comment: ""),
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(type: .compose),
                userInfo: userInfo
            )
        ]
    }
}

extension ClendarApp {

    // MARK: - Private

    private func configure() {
        #if os(iOS)
        UIApplication.shared.applicationIconBadgeNumber = 0
        ReviewManager().trackLaunch()
        #endif

        logger.logLevel = .debug
        SwiftDate.defaultRegion = Region.local
        Shift.configureWithAppName(AppInfo.appName)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            shortcutItemToProcess = shortcutItem
        }

        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = CustomSceneDelegate.self
        return sceneConfiguration
    }
}

class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        shortcutItemToProcess = shortcutItem
    }
}
