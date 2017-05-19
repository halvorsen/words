//
//  MenuViewController.swift
//  WordGame
//
//  Created by Aaron Halvorsen on 5/2/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit
import GCHelper

class MenuViewController: UIViewController {
    var delegate: restartDelegate?// = nil
    let slide1 = UIView()
    var winRank = 3
    var percentageRank = 4
    var wins = Int()
    var loses = Int()
    var menuIcon = UIImageView()
    let myColor = CustomColor()
    
    override func viewWillAppear(_ animated: Bool) {

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wins = Set1.wins
        loses = Set1.loses
        self.delegate = presentingViewController! as? restartDelegate
        let pan = UIPanGestureRecognizer(target: self, action: #selector(MenuViewController.swipeFunc(_:)))
        view.addGestureRecognizer(pan)
        view.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.8)
        
        slide1.backgroundColor = .white
        slide1.frame = CGRect(x: 40*sw/375, y: 70*sh/667, width: 295*sw/375, height: 570*sh/667)
        slide1.layer.cornerRadius = sw/50
        slide1.layer.masksToBounds = true
        slide1.layer.borderColor = UIColor.black.cgColor
        slide1.layer.borderWidth = 2
        view.addSubview(slide1)
        menuIcon.image = #imageLiteral(resourceName: "menuIcon")
        menuIcon.frame = CGRect(x: 109*sw/375, y: 84*sh/667, width: 77*sw/375, height: 72*sw/375)
        slide1.addSubview(menuIcon)
        let labels : [(y: CGFloat, height: CGFloat, fontSize: CGFloat, text: String, color: UIColor)] = [
            (205,50,48,"Wins: \(wins)", myColor.purple),
            (258,24,20,"Loses: \(loses)", .black),
           // (304,21,16,"Game Center Rank: #\(percentageRank)", myColor.white180),
            //(444,15,14,"Resume", myColor.teal),
            //(510,15,14,"New Game", myColor.purple)
        ]
        
        for (y,height,fontSize,text,color) in labels {
            let label = UILabel()
            label.frame = CGRect(x: 0, y: y*sh/667, width: slide1.bounds.width, height: height*sh/667)
            label.font = UIFont(name: "HelveticaNeue-Bold", size: fontSize*fontSizeMultiplier)
            label.text = text
            label.textAlignment = .center
            label.textColor = color
            slide1.addSubview(label)
        }
        let button = UIButton()
        button.setTitle("Game Center Rank: #\(percentageRank)", for: UIControlState.normal)
        button.frame = CGRect(x: 0, y: 304*sh/667, width: slide1.bounds.width, height: 50*sh/667)
        button.addTarget(self, action: #selector(MenuViewController.gCenter(_:)), for: .touchUpInside)
                button.setTitleColor(myColor.white180, for: .normal)
        button.titleLabel!.font =  UIFont(name: "HelveticaNeue-Bold", size: 16*fontSizeMultiplier)
        slide1.addSubview(button)
        
        
        let buttons : [(y: CGFloat, text: String, selector: Selector, color: UIColor)] = [
            (428,"Resume",#selector(MenuViewController.resumeFunc(_:)),myColor.teal),
            (494,"New Game",#selector(MenuViewController.newGameFunc(_:)),myColor.purple)
        ]
        
        for (y,text,selector,color) in buttons {
            let button = UIButton()
            button.setTitle(text, for: UIControlState.normal)
            button.frame = CGRect(x: 67*sw/375, y: y*sh/667, width: 161*sw/375, height: 48*sh/667)
            button.layer.borderWidth = 2
            button.layer.cornerRadius = 2
            button.layer.borderColor = UIColor.black.cgColor
            button.addTarget(self, action: selector, for: .touchUpInside)
            button.layer.borderWidth = 1
            button.layer.borderColor = color.cgColor
            button.setTitleColor(color, for: .normal)
            
            button.titleLabel!.font =  UIFont(name: "HelveticaNeue-Bold", size: 14*fontSizeMultiplier)
            slide1.addSubview(button)
            
            
        }
       

    }
    
    override func viewDidAppear(_ animated: Bool) {
       GameCenter.shared.auth()
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
        if !Set1.winState {
        Set1.loses += 1
        }
        Set1.winState = false
        delegate?.restart()
        dismiss(animated: true, completion: nil)
        
    }
    @objc private func gCenter(_ button: UIButton) {
        
            GCHelper.sharedInstance.showGameCenter(self, viewState: .leaderboards)
        
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

