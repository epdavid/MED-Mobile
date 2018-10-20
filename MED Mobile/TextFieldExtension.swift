//
//  TextFieldExtension.swift
//  MED Mobile
//
//  Created by Evan David on 10/19/18.
//  Copyright © 2018 Evan David. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func loadDropdownData(data: [String]) {
        self.inputView = SearchOption(pickerData: data, dropdownField: self)
        self.tintColor = .clear
        
    }
}
