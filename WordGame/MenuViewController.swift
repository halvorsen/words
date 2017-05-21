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
   // var delegate: restartDelegate?// = nil
    //let slide1 = UIView()
    var winRank = 3
    var percentageRank = 4
    var wins = Int()
    var loses = Int()
    var menuIcon = UIImageView()
    let myColor = CustomColor()
    var newGame = false
    
    override func viewWillAppear(_ animated: Bool) {

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wins = Set1.wins
        loses = Set1.loses
        //self.delegate = presentingViewController! as? restartDelegate
        let pan = UIPanGestureRecognizer(target: self, action: #selector(MenuViewController.swipeFunc(_:)))
        view.addGestureRecognizer(pan)
        view.backgroundColor = .white
        
        menuIcon.image = #imageLiteral(resourceName: "menuIcon")
        menuIcon.frame = CGRect(x: 139*sw/375, y: 58*sh/667, width: 97*sw/375, height: 91*sw/375)
        view.addSubview(menuIcon)
        let labels : [(y: CGFloat, height: CGFloat, fontSize: CGFloat, text: String, color: UIColor)] = [
            (215,50,61,"Wins: \(wins)", myColor.purple),
            (280,24,26,"Loses: \(loses)", .black),
           // (304,21,16,"Game Center Rank: #\(percentageRank)", myColor.white180),
            //(444,15,14,"Resume", myColor.teal),
            //(510,15,14,"New Game", myColor.purple)
        ]
        
        for (y,height,fontSize,text,color) in labels {
            let label = UILabel()
            label.frame = CGRect(x: 0, y: y*sh/667, width: view.bounds.width, height: height*sh/667)
            label.font = UIFont(name: "HelveticaNeue-Bold", size: fontSize*fontSizeMultiplier)
            label.text = text
            label.textAlignment = .center
            label.textColor = color
            view.addSubview(label)
        }
        let button = UIButton()
        button.setTitle("Game Center Leaderboard", for: UIControlState.normal)
        button.frame = CGRect(x: 0, y: 340*sh/667, width: view.bounds.width, height: 23*sh/667)
        button.addTarget(self, action: #selector(MenuViewController.gCenter(_:)), for: .touchUpInside)
                button.setTitleColor(myColor.white180, for: .normal)
        button.titleLabel!.font =  UIFont(name: "HelveticaNeue-Medium", size: 21*fontSizeMultiplier)
        view.addSubview(button)
        
        
        let buttons : [(y: CGFloat, text: String, selector: Selector, color: UIColor)] = [
            (495,"Resume",#selector(MenuViewController.resumeFunc(_:)),myColor.teal),
            (579,"New Game",#selector(MenuViewController.newGameFunc(_:)),myColor.purple)
        ]
        
        for (y,text,selector,color) in buttons {
            let button = UIButton()
            button.setTitle(text, for: UIControlState.normal)
            button.frame = CGRect(x: 84*sw/375, y: y*sh/667, width: 204*sw/375, height: 62*sh/667)
            button.layer.borderWidth = 4
            button.layer.cornerRadius = 2
            button.layer.borderColor = UIColor.black.cgColor
            button.addTarget(self, action: selector, for: .touchUpInside)
            button.layer.borderWidth = 1
            button.layer.borderColor = color.cgColor
            button.setTitleColor(color, for: .normal)
            button.titleLabel!.font =  UIFont(name: "HelveticaNeue-Bold", size: 18*fontSizeMultiplier)
            view.addSubview(button)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
    }
    
    @objc private func resumeFunc(_ button: UIButton) {
        
            self.performSegue(withIdentifier: "fromMenuToGame", sender: self)
        
    }
    
    @objc private func newGameFunc(_ button: UIButton) {
        if !Set1.winState {
        Set1.loses += 1
        }
        Set1.winState = false
        newGame = true
        self.performSegue(withIdentifier: "fromMenuToGame", sender: self)
    }
    @objc private func gCenter(_ button: UIButton) {
        
            GCHelper.sharedInstance.showGameCenter(self, viewState: .leaderboards)
        
    }
    @objc private func swipeFunc(_ gesture: UIPanGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            if gesture.state == .began {
                
                self.view.frame.origin.x -= self.sw
            }
            if gesture.state == .ended {
                
                self.delay(bySeconds: 0.5) {
                    self.dismiss(animated: true, completion: nil)
                }

            }
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let yourVC = segue.destination as? GameViewController {
            if newGame {
            yourVC.newGame = true
            }
        }
    }
    
    
    
    
}


