//
//  UIView+addBorder.swift
//  BCSwap
//
//  Created by Mark Lee on 4/29/19.
//  Copyright © 2019 Mark Lee. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addBorder(width: CGFloat, radius: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = radius
    }
    
    func noBorder() {
        self.layer.borderWidth = 0.0
    }
}
