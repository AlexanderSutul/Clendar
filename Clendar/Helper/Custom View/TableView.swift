//
//  TableView.swift
//  Clendar
//
//  Created by Vinh Nguyen on 31/3/19.
//  Copyright © 2019 Vinh Nguyen. All rights reserved.
//

import Foundation

class TableView: UITableView {
    var contentSizeDidChange: SizeUpdateHandler?

    override var contentSize: CGSize {
        didSet {
            self.contentSizeDidChange.flatMap { $0(self.contentSize) }
        }
    }
}
