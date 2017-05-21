//
//  HorizontalSlide.swift
//  WordGame
//
//  Created by Aaron Halvorsen on 5/19/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit

class HorizontalSlide: UIStoryboardSegue {
    
//    override func perform() {
        
        //set the ViewControllers for the animation
//        
//        let sourceView = self.source.view as UIView!
//        let destinationView = self.destination.view as UIView!
//        
//        
//        let window = UIApplication.shared.delegate?.window!
//        //set the destination View center
//        destinationView?.center = CGPoint(x: (sourceView?.center.x)!, y: (sourceView?.center.y)! - (destinationView?.center.y)!)
//        
//        // the Views must be in the Window hierarchy, so insert as a subview the destionation above the source
//        window?.insertSubview(destinationView!, aboveSubview: sourceView!)
//        
//        //create UIAnimation- change the views's position when present it
//        UIView.animate(withDuration: 0.4,
//                       animations: {
//                        destinationView?.center = CGPoint(x: (sourceView?.center.x)!, y: (sourceView?.center.y)!)
//                        sourceView?.center = CGPoint(x: (sourceView?.center.x)!, y: 0 + 2 * (destinationView?.center.y)!)
//        }, completion: {
//            (value: Bool) in
//            self.source.navigationController?.pushViewController(self.destination, animated: false)
//            
//            
//        })
                override func perform(){
        
                    let slideView = destination.view
        
                    source.view.addSubview(slideView!)
                    slideView?.transform = CGAffineTransform(translationX: source.view.frame.size.width, y: 0)
        
                    UIView.animate(withDuration: 0.25,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.curveEaseInOut,
                                   animations: {
                                    slideView?.transform = CGAffineTransform.identity
                    }, completion: { finished in
        
                        self.source.present(self.destination as UIViewController,animated: false, completion: nil)
                        slideView?.removeFromSuperview()
                        slideView?.transform
                    })
    }
}

