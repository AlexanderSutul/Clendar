//
//  SettingsViewController.swift
//  Clendar
//
//  Created by Vinh Nguyen on 29/3/19.
//  Copyright © 2019 Vinh Nguyen. All rights reserved.
//

import UIKit
import PanModal

final class SettingsNavigationController: BaseNavigationController, PanModalPresentable {

    let settings = SettingsViewController()

    // MARK: - Pan Modal Presentable

    var panScrollable: UIScrollView? {
        return (topViewController as? PanModalPresentable)?.panScrollable
    }

    var longFormHeight: PanModalHeight {
        return .maxHeight
    }

    var shortFormHeight: PanModalHeight {
        return longFormHeight
    }

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()
        pushViewController(settings, animated: false)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        let vc = super.popViewController(animated: animated)
        panModalSetNeedsLayoutUpdate()
        return vc
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        panModalSetNeedsLayoutUpdate()
    }
}

final class SettingsViewController: BaseViewController, PanModalPresentable {

    // MARK: - Pan Modal Presentable

    var panScrollable: UIScrollView? {
        return tableView
    }

    // MARK: - Properties

    lazy var tableView = TableView(frame: .zero)
}
