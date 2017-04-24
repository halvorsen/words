//
//  Slot.swift
//  WordGame
//
//  Created by Aaron Halvorsen on 4/23/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit

class Slot: UIView {
    
    var isOccupied = false
    var row = 1
    var column = 1
    var isPermanentlyOccupied = false
    var isOccupiedFromStart = false
    var slotIndex = 1
    
    
}

public struct SlotIndex {
    static var index = [Slot]()
}
