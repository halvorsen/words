//
//  UnwindCustomSegue.swift
//  WordGame
//
//  Created by Aaron Halvorsen on 5/20/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit

class UnwindCustomSegue: UIStoryboardSegue {
    
    //set the ViewControllers for the animation
    override func perform() {
    
    let sourceView = source.view
    let destinationView = destination.view
    let window = UIApplication.shared.delegate?.window!
    
    // 1. beloveSubview
    window?.insertSubview(destinationView!, belowSubview: sourceView!)
    
    
    //2. y cordinate change
    destinationView?.center = CGPoint(x: (sourceView?.center.x)!, y: (sourceView?.center.y)! + (destinationView?.center.y)!)
    
    
    //3. create UIAnimation- change the views's position when present it
    UIView.animate(withDuration: 0.4,
    animations: {
    destinationView?.center = CGPoint(x: (sourceView?.center.x)!, y: (sourceView?.center.y)!)
    sourceView?.center = CGPoint(x: (sourceView?.center.x)!, y: 0 - 2 * (destinationView?.center.y)!)
    }, completion: {
    (value: Bool) in
    //4. dismiss
    
    destinationView?.removeFromSuperview()
    if let navController = self.destination {
    navController.popToViewController(self.destination, animated: false)
    }
    
    
    })
    }
}
