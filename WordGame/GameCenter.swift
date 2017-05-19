//
//  GameCenter.swift
//  Fooble
//
//  Created by Aaron Halvorsen on 1/4/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import Foundation
import GCHelper

struct GameCenter {
    static let shared = GameCenter()
    func addDataToGameCenter(wins: Int) {
        if wins > 0 {
            GCHelper.sharedInstance.reportLeaderboardIdentifier("24f4nvaeroin49043", score: wins)
        }
        
        
    }
    
    func auth() {
        GCHelper.sharedInstance.authenticateLocalUser()
    }
    
    
    
}
