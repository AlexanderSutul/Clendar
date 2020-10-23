//
//  EventListTableViewCell.swift
//  Clendar
//
//  Created by Vinh Nguyen on 10/23/20.
//  Copyright © 2020 Vinh Nguyen. All rights reserved.
//

import UIKit
import EventKit

class EventListTableViewCell: UITableViewCell {

    func configure(event: EKEvent) {
        let displayText = event.displayText
        textLabel?.text = "[\(displayText)] \(event.title ?? "")"
        textLabel?.font = .fontWithSize(15, weight: .medium)
        textLabel?.textColor = .appGray

        let view = UIView()
        view.backgroundColor = UIColor.init(cgColor: event.calendar.cgColor)
        view.frame = CGRect(x: 0, y: 1, width: 3, height: frame.size.height - 3)
        contentView.addSubview(view)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }

}
