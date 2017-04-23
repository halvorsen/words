//
//  Board.swift
//  WordGame
//
//  Created by Aaron Halvorsen on 4/22/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit

class Board: UIScrollView {
    
    let myColor = CustomColor()
    static let sharedInstance = Board()
    var slots = [(view:UIView,row:Int,column:Int,isOcc:Bool)]()
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
     
        self.frame = CGRect(x: 15*sw/375, y: 117*sh/667, width: 345*sw/375, height: 345*sw/375)
        self.backgroundColor = myColor.white245
        
        for i in 0...14 {
            for j in 0...14 {
                let slot = UIView()
                slot.frame = CGRect(x: 1*sw/375 + CGFloat(i)*23*sw/375, y: 1*sw/375 + CGFloat(j)*23*sw/375, width: 22*sw/375, height: 22*sw/375)
                slot.backgroundColor = UIColor(colorLiteralRed: 72/255, green: 72/255, blue: 72/255, alpha: 1.0)
                slot.layer.cornerRadius = slot.frame.width*3/22
                let tuple = (slot,j,i,false)
                slots.append(tuple)
                let slot2 = UIView()
                slot2.frame = CGRect(x: 1*sw/375 + CGFloat(i)*23*sw/375, y: 1.5*sw/375 + CGFloat(j)*23*sw/375, width: 22*sw/375, height: 21.5*sw/375)
                slot2.backgroundColor = myColor.white234
                slot2.layer.cornerRadius = slot.frame.width*3/22
              
                self.addSubview(slot)
                self.addSubview(slot2)
            }
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
