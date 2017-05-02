//
//  MenuViewController.swift
//  WordGame
//
//  Created by Aaron Halvorsen on 5/2/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    var delegate: restartDelegate?// = nil
    let slide1 = UIView()
    var winRank = 3
    var percentageRank = 4
    var wins = Int()
    var loses = Int()
    
    override func viewWillAppear(_ animated: Bool) {

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wins = Set1.wins
        loses = Set1.loses
        self.delegate = presentingViewController! as! restartDelegate
        let pan = UIPanGestureRecognizer(target: self, action: #selector(MenuViewController.swipeFunc(_:)))
        view.addGestureRecognizer(pan)
        view.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.8)
        
        slide1.backgroundColor = .white
        slide1.frame = CGRect(x: 40*sw/375, y: 70*sh/667, width: 295*sw/375, height: 527*sh/667)
        slide1.layer.cornerRadius = sw/50
        slide1.layer.masksToBounds = true
        slide1.layer.borderColor = UIColor.black.cgColor
        slide1.layer.borderWidth = 2
        view.addSubview(slide1)
        
        let labels : [(y: CGFloat, height: CGFloat, fontSize: CGFloat, text: String)] = [
            (104,50,48,"Wins! \(wins)"),
            (154,24,20,"Loses: \(loses)"),
            (228,21,16,"Game Center Win Rank:"),
            (249,24,16,"#\(winRank)"),
            (273,21,16,"Game Center Percentage Rank:"),
            (297,24,16,"#\(percentageRank)"),
            (388,48,16,"Resume"),
            (454,48,16,"New Game")
        ]
        
        for (y,height,fontSize,text) in labels {
            let label = UILabel()
            label.frame = CGRect(x: 0, y: y*sh/667, width: slide1.bounds.width, height: height*sh/667)
            label.font = UIFont(name: "HelveticaNeue-Bold", size: fontSize*fontSizeMultiplier)
            label.text = text
            label.textAlignment = .center
            slide1.addSubview(label)
        }
        
        let buttons : [(y: CGFloat, text: String, selector: Selector)] = [
            (388,"Resume",#selector(MenuViewController.resumeFunc(_:))),
            (454,"New Game",#selector(MenuViewController.newGameFunc(_:)))
        ]
        
        for (y,text,selector) in buttons {
            let button = UIButton()
//            button.setTitle(text, for: UIControlState.normal)
            button.frame = CGRect(x: 67*sw/375, y: y*sh/667, width: 161*sw/375, height: 48*sh/667)
            button.layer.borderWidth = 2
            button.layer.cornerRadius = 2
            button.layer.borderColor = UIColor.black.cgColor
            button.addTarget(self, action: selector, for: .touchUpInside)
            
//            button.titleLabel!.font =  UIFont(name: "HelveticaNeue-Bold", size: 16*fontSizeMultiplier)
//             button.titleLabel!.textColor = .black
            slide1.addSubview(button)
            
            
        }
       

    }
    
    
    
    @objc private func resumeFunc(_ button: UIButton) {
        UIView.animate(withDuration: 0.5) {
            
            //self.slide1.frame.origin.x -= self.sw
            
        }
        self.delay(bySeconds: 0.5) {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    @objc private func newGameFunc(_ button: UIButton) {
        Set1.loses += 1
        Set1.winState = false
        delegate?.restart()
        dismiss(animated: true, completion: nil)
        
    }
    @objc private func swipeFunc(_ gesture: UIPanGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            if gesture.state == .began {
                
                self.slide1.frame.origin.x -= self.sw
            }
            if gesture.state == .ended {
                
                self.delay(bySeconds: 0.5) {
                    self.dismiss(animated: true, completion: nil)
                }

            }
        }
        
    }
    
    
    
    
}

