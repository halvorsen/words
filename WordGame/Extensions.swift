//
//  Extensions.swift
//  WordGame
//
//  Created by Aaron Halvorsen on 4/22/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit

extension UIView {
    
    var sw: CGFloat {get{return UIScreen.main.bounds.width}}
    var sh: CGFloat {get{return UIScreen.main.bounds.height}}
    var fontSizeMultiplier: CGFloat {get{return UIScreen.main.bounds.width / 375}}
    
}

extension UIViewController {
    
    var sw: CGFloat {get{return UIScreen.main.bounds.width}}
    var sh: CGFloat {get{return UIScreen.main.bounds.height}}
    var fontSizeMultiplier: CGFloat {get{return UIScreen.main.bounds.width / 375}}
}

struct CustomColor {
    let white245 = UIColor(colorLiteralRed: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
    let white234 = UIColor(colorLiteralRed: 227/255, green: 227/255, blue: 227/255, alpha: 1.0)
}
