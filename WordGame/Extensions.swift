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
    let white245 = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    let white234 = UIColor(colorLiteralRed: 227/255, green: 227/255, blue: 227/255, alpha: 1.0)
    let white238 = UIColor(colorLiteralRed: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
    let teal = UIColor(colorLiteralRed: 112/255, green: 194/255, blue: 206/255, alpha: 1.0)
    let purple = UIColor(colorLiteralRed: 176/255, green: 137/255, blue: 231/255, alpha: 1.0)
    let white180 = UIColor(colorLiteralRed: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
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

class ProgressHUD: UIVisualEffectView {
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    let label: UILabel = UILabel()
    let blurEffect = UIBlurEffect(style: .light)
    let vibrancyView: UIVisualEffectView
    
    init(text: String) {
        self.text = text
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.text = ""
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        contentView.addSubview(vibrancyView)
        contentView.addSubview(activityIndictor)
        contentView.addSubview(label)
        activityIndictor.startAnimating()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = self.superview {
            
            let width = superview.frame.size.width / 2.3
            let height: CGFloat = 50.0
            self.frame = CGRect(x: superview.frame.size.width / 2 - width / 2,
                                y: superview.frame.height / 2 - height / 2,
                                width: width,
                                height: height)
            vibrancyView.frame = self.bounds
            
            let activityIndicatorSize: CGFloat = 40
            activityIndictor.frame = CGRect(x: 5,
                                            y: height / 2 - activityIndicatorSize / 2,
                                            width: activityIndicatorSize,
                                            height: activityIndicatorSize)
            
            layer.cornerRadius = 8.0
            layer.masksToBounds = true
            label.text = text
            label.textAlignment = NSTextAlignment.center
            label.frame = CGRect(x: activityIndicatorSize + 5,
                                 y: 0,
                                 width: width - activityIndicatorSize - 15,
                                 height: height)
            label.textColor = UIColor.white
            label.font = UIFont.boldSystemFont(ofSize: 16)
        }
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
}


