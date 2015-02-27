//
//  STPYNavigationBarView.swift
//  SwiftSteppy
//
//  Created by Andrew Finke on 1/10/15.
//  Copyright (c) 2015 Andrew Finke. All rights reserved.
//

import UIKit

class STPYNavigationBarView: UIView {
    override func willMoveToWindow(newWindow: UIWindow?) {
        layer.shadowOffset = CGSizeMake(0, 1.0 / UIScreen.mainScreen().scale)
        layer.shadowRadius = 0
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.25
    }
}
