//
//  Tile.swift
//  WordGame
//
//  Created by Aaron Halvorsen on 4/21/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit
//let sw = UIScreen.main.bounds.width
//let sh = UIScreen.main.bounds.height

class Tile: UIView {
    let myColor = CustomColor()

    enum size {
        case small
        case medium
        case large
    }
    
    enum symbol: String {
        case a = "A",b = "B",c = "C",d = "D",e = "E",f = "F",g = "G",h = "H",i = "I",j = "J",k = "K",l = "L",m = "M",n = "N",o = "O",p = "P",q = "Q",r = "R",s = "S",t = "T",u = "U",v = "V",w = "W",x = "X",y = "Y",z = "Z"
    }
    
    enum WhereInPlay {
        case board
        case atBat
        case onDeck
        case pile
        case trash
    }
    
    var isLockedInPlace = Bool() {didSet{
        if isLockedInPlace && !isStarterBlock {
            topOfBlock.backgroundColor = myColor.black80
            text.textColor = .white
        }
        }
        
        }
    var isBuildable = false
    var isStarterBlock = false
    var onDeckTileOrder: Int?
    var atBatTileOrder: Int?
    var slotsIndex: Int?
    var row: Int?
    var column: Int?
    var mySymbol: symbol = .a
    var mySize: size = .medium { didSet { changeBlockSize() } }
    var myWhereInPlay: WhereInPlay = .atBat {
        didSet {
            switch myWhereInPlay {
            case .atBat:
                self.mySize = .large
            case .onDeck:
                self.mySize = .medium
            case .board:
                self.mySize = .small
                if Set1.isZoomed {
                    self.mySize = .large
                }
                case .pile: break
                case .trash: break
            }
            
        }
    }
    var topOfBlock = UILabel()
    var shadowOfBlock = UILabel()
    var text = UILabel()
    
    var fontSize: CGFloat = 15
    
    func changeBlockSize() {
        switch mySize {
        case .small:
            self.frame.size = CGSize(width: 23*sw/375, height: 23*sw/375)
            fontSize = 13*fontSizeMultiplier
        case .medium:
            self.frame.size = CGSize(width: 34*sw/375, height: 34*sw/375)
            fontSize = 18*fontSizeMultiplier
        case .large:
            self.frame.size = CGSize(width: 49*sw/375, height: 49*sw/375)
            fontSize = 36*fontSizeMultiplier
        }
        setContents()
    }
    
    private func setContents() {
        topOfBlock.frame = CGRect(x: 0, y: 0, width: 0.96*self.bounds.width, height: 0.96*self.bounds.height)
        topOfBlock.layer.borderWidth = 1
        topOfBlock.layer.borderColor = UIColor.black.cgColor
        topOfBlock.backgroundColor = .white
        topOfBlock.layer.cornerRadius = self.bounds.width/10
        topOfBlock.layer.masksToBounds = true
        text.frame = CGRect(x: 0, y: 0, width: 0.96*self.bounds.width, height: 0.96*self.bounds.height)
        text.backgroundColor = .clear
        text.text = mySymbol.rawValue
        text.font = UIFont(name: "HelveticaNeue-Bold", size: fontSize)
        text.textColor = .black
        text.textAlignment = .center
        shadowOfBlock.frame = CGRect(x: 0.04*self.bounds.width, y: 0.04*self.bounds.width, width: 0.96*self.bounds.width, height: 0.96*self.bounds.height)
        shadowOfBlock.backgroundColor = .black
        shadowOfBlock.layer.cornerRadius = self.bounds.width/10
        shadowOfBlock.layer.masksToBounds = true
        if isLockedInPlace && !isStarterBlock {
            topOfBlock.backgroundColor = myColor.black80
            text.textColor = .white
        }
    }
    var isFirstInit = true
    init() {
//        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
//        self.frame = CGRect(x: 0, y: 0, width: 47*sw/375, height: 47*sw/375)
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.frame = CGRect(x: 15*sw/375, y: 616*sh/667, width: 34*sw/375, height: 34*sw/375)
        self.isUserInteractionEnabled = true
        if isFirstInit {
        setContents()
            isFirstInit = false
        }
        self.addSubview(shadowOfBlock)
        self.addSubview(topOfBlock)
       
        self.addSubview(text)
        changeBlockSize()

    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touch = touches.first as! UITouch
//                superview!.isUserInteractionEnabled = false
//    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        superview!.isUserInteractionEnabled = true
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
