//
//  TutorialViewController.swift
//  WordGame
//
//  Created by Aaron Halvorsen on 4/30/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    let slide1 = UIImageView()
    let slide2 = UIImageView()
    let slide3 = UIImageView()
    let slide4 = UIImageView()
    let myColor = CustomColor()
    
    var viewOnScreen = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pan = UIPanGestureRecognizer(target: self, action: #selector(TutorialViewController.swipeFunc(_:)))
        view.addGestureRecognizer(pan)
        view.backgroundColor = myColor.white238//UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.8)
        viewOnScreen = slide1
        setupSlide1()
        setupSlide2()
        setupSlide3()
        setupSlide4()
        
    }
    @objc private func swipeFunc(_ gesture: UIPanGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            if gesture.state == .began {
                switch self.viewOnScreen {
                case self.slide1:
                    self.slide1.frame.origin.x -= self.sw
                    self.slide2.frame.origin.x -= self.sw
                case self.slide2:
                    self.slide2.frame.origin.x -= self.sw
                    self.slide3.frame.origin.x -= self.sw
                case self.slide3:
                    self.slide3.frame.origin.x -= self.sw
                    self.slide4.frame.origin.x -= self.sw
                case self.slide4:
                    self.slide4.frame.origin.x -= self.sw
                    
                default: break
                }
            }
        }
            if gesture.state == .ended {
                switch viewOnScreen {
                case slide1: viewOnScreen = slide2
                case slide2: viewOnScreen = slide3
                case slide3: viewOnScreen = slide4
                case slide4: delay(bySeconds: 0.5) {
                    self.dismiss(animated: true, completion: nil)
                    }
                default: break
                }
            
        }
    }
    private func setupSlide1() {
        slide1.frame = CGRect(x: 40*sw/375, y: 70*sh/667, width: 295*sw/375, height: 527*sh/667)
        slide1.image = #imageLiteral(resourceName: "Tutorial1")
        slide1.layer.cornerRadius = sw/50
        slide1.layer.masksToBounds = true
        view.addSubview(slide1)
    }
    private func setupSlide2() {
        slide2.frame = CGRect(x: 40*sw/375 + sw, y: 70*sh/667, width: 295*sw/375, height: 527*sh/667)
        slide2.image = #imageLiteral(resourceName: "Tutorial2")
        slide2.layer.cornerRadius = sw/50
        slide2.layer.masksToBounds = true
        view.addSubview(slide2)
    }
    private func setupSlide3() {
        slide3.frame = CGRect(x: 40*sw/375 + sw, y: 70*sh/667, width: 295*sw/375, height: 527*sh/667)
        slide3.image = #imageLiteral(resourceName: "Tutorial3")
        slide3.layer.cornerRadius = sw/50
        slide3.layer.masksToBounds = true
        view.addSubview(slide3)
    }
    private func setupSlide4() {
        slide4.frame = CGRect(x: 40*sw/375 + sw, y: 70*sh/667, width: 295*sw/375, height: 527*sh/667)
        slide4.image = #imageLiteral(resourceName: "Tutorial4")
        slide4.layer.cornerRadius = sw/50
        slide4.layer.masksToBounds = true
        view.addSubview(slide4)
    }
    
}
