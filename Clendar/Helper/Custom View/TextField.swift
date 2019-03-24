//
//  TextField.swift
//  Clendar
//
//  Created by Vinh Nguyen on 24/3/19.
//  Copyright © 2019 Vinh Nguyen. All rights reserved.
//

import UIKit

class TextField: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.attributedPlaceholder = NSAttributedString(string: (self.placeholder ?? ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
    }
}
