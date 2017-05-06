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
    
    func delay(bySeconds seconds: Double, dispatchLevel: DispatchLevel = .main, closure: @escaping () -> Void) {
        let dispatchTime = DispatchTime.now() + seconds
        dispatchLevel.dispatchQueue.asyncAfter(deadline: dispatchTime, execute: closure)
    }
    
    enum DispatchLevel {
        case main, userInteractive, userInitiated, utility, background
        var dispatchQueue: DispatchQueue {
            switch self {
            case .main:                 return DispatchQueue.main
            case .userInteractive:      return DispatchQueue.global(qos: .userInteractive)
            case .userInitiated:        return DispatchQueue.global(qos: .userInitiated)
            case .utility:              return DispatchQueue.global(qos: .utility)
            case .background:           return DispatchQueue.global(qos: .background)
            }
        }
    }
}

struct CustomColor {
    let white245 = UIColor(colorLiteralRed: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
    let white234 = UIColor(colorLiteralRed: 227/255, green: 227/255, blue: 227/255, alpha: 1.0)
    let black80 = UIColor(colorLiteralRed: 80/255, green: 80/255, blue: 80/255, alpha: 1.0)
}

public struct Set1 {
    
    public static var isZoomed: Bool = false
    public static var wins: Int = 0 { didSet {
        LoadSaveCoreData.sharedInstance.saveWinLoses()
        print("wins: \(wins)")
        }
    }
    public static var loses: Int = 0 { didSet {
        LoadSaveCoreData.sharedInstance.saveWinLoses()
        print("loses: \(loses)")
        }
        }
    public static var winState: Bool = false
    public static var indexBuildable = [Int]()
    public static var onDeckRawValue = [String]()
    public static var atBatRawValue = [String]()
    public static var buildableRawValue = [String]()
    public static var indexStart = [Int]()
    public static var startRawValue = [String]()
    public static var pileAmount = Int()

}

protocol restartDelegate: class {
    func restart()
}


