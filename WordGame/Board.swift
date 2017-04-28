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
    var slots = [Slot]()
    var slots2 = [UIView]()
    let v = UIView()
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
     
        self.frame = CGRect(x: 15*sw/375, y: 117*sh/667, width: 345*sw/375, height: 345*sw/375)
        v.frame = self.bounds
        v.backgroundColor = myColor.white245
        self.addSubview(v)
        
        var count = 0
        for i in 0...14 {
            for j in 0...14 {
                let slot = Slot()
                slot.frame = CGRect(x: 1*sw/375 + CGFloat(i)*23*sw/375, y: 1*sw/375 + CGFloat(j)*23*sw/375, width: 22*sw/375, height: 22*sw/375)
                slot.backgroundColor = UIColor(colorLiteralRed: 72/255, green: 72/255, blue: 72/255, alpha: 1.0)
                slot.layer.cornerRadius = slot.frame.width*3/22
                slot.row = j
                slot.column = i
                slot.slotIndex = count
                SlotIndex.index.append(slot)
                slots.append(slot)
                let slot2 = UIView()
                slot2.frame = CGRect(x: 1*sw/375 + CGFloat(i)*23*sw/375, y: 1.5*sw/375 + CGFloat(j)*23*sw/375, width: 22*sw/375, height: 21.5*sw/375)
                slot2.backgroundColor = myColor.white234
                slot2.layer.cornerRadius = slot.frame.width*3/22
                slots2.append(slot2)
                count += 1
                v.addSubview(slot)
                v.addSubview(slot2)
            }
        }
        self.isUserInteractionEnabled = false
     
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let scale: CGFloat = 2.13
    func zoomIn(callback: () -> Void) {
        
        v.frame.size = CGSize( width: scale*345*sw/375, height: scale*345*sw/375 )
        
        var count = 0
        for i in 0...14 {
            for j in 0...14 {
                
                slots[count].frame = CGRect(x: scale*1*sw/375 + scale*CGFloat(i)*23*sw/375, y: scale*1*sw/375 + scale*CGFloat(j)*23*sw/375, width: scale*22*sw/375, height: scale*22*sw/375)
                slots[count].layer.cornerRadius = scale*slots[count].frame.width*3/44
                
                slots2[count].frame = CGRect(x: scale*1*sw/375 + scale*CGFloat(i)*23*sw/375, y: scale*1.5*sw/375 + scale*CGFloat(j)*23*sw/375, width: scale*22*sw/375, height: scale*21.5*sw/375)
                slots2[count].layer.cornerRadius = scale*slots2[count].frame.width*3/44
                count += 1
            }
        }
        self.contentSize = CGSize(width: self.bounds.width*scale, height: self.bounds.height*scale)
        Set1.isZoomed = true
        callback()
    }
    
    func zoomOut(callback: () -> Void) {
        let scale: CGFloat = 1
        v.frame.size = CGSize( width: scale*345*sw/375, height: scale*345*sw/375 )
        
        var count = 0
        for i in 0...14 {
            for j in 0...14 {
                
                slots[count].frame = CGRect(x: 1*sw/375 + CGFloat(i)*23*sw/375, y: 1*sw/375 + CGFloat(j)*23*sw/375, width: 22*sw/375, height: 22*sw/375)
                slots[count].layer.cornerRadius = scale*slots[count].frame.width*3/22
                
                slots2[count].frame = CGRect(x: 1*sw/375 + CGFloat(i)*23*sw/375, y: 1.5*sw/375 + CGFloat(j)*23*sw/375, width: 22*sw/375, height: 21.5*sw/375)
                slots2[count].layer.cornerRadius = scale*slots2[count].frame.width*3/22
                count += 1
            }
        }
        self.contentSize = self.bounds.size
        Set1.isZoomed = false
        self.contentOffset.x = 0
        self.contentOffset.y = 0
        callback()
    }

    
    
    
    


}
