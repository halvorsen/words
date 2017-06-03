//
//  TutorialViewController.swift
//  WordGame
//
//  Created by Aaron Halvorsen on 4/30/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class TutorialViewController: UIViewController {
    let slide1 = UIImageView()
    let slide2 = UIImageView()
    let slide3 = UIImageView()
    let slide4 = UIImageView()
    let myColor = CustomColor()
    
    var viewOnScreen = UIImageView()
    
    
    
    func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        self.dismiss(animated: true, completion: nil)
    }
    
    private func playVideo() {
        print("playVideo")
        guard let path = Bundle.main.path(forResource: "AppPreviewWord", ofType:"mp4") else {
            debugPrint("video.m4v not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        NotificationCenter.default.addObserver(self, selector: #selector(TutorialViewController.playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)//videoPlayer.currentItem)
        present(playerController, animated: true) {
            player.play()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panLeft = UISwipeGestureRecognizer(target: self, action: #selector(TutorialViewController.swipeFuncLeft(_:)))
        let panRight = UISwipeGestureRecognizer(target: self, action: #selector(TutorialViewController.swipeFuncRight(_:)))
        panLeft.direction = .left
        panRight.direction = .right
        view.addGestureRecognizer(panLeft)
        view.addGestureRecognizer(panRight)
        
        view.backgroundColor = myColor.white238//UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.8)
        viewOnScreen = slide1
        setupSlide1()
        setupSlide2()
        setupSlide3()
        setupSlide4()
        
    }
    @objc private func swipeFuncRight(_ gesture: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            
            switch self.viewOnScreen {
            case self.slide1:
                break
                
            default:
                self.slide2.frame.origin.x += self.sw
                self.slide1.frame.origin.x += self.sw
                self.slide4.frame.origin.x += self.sw
                self.slide3.frame.origin.x += self.sw
                
            }
        }
        switch viewOnScreen {
            
        case slide2: viewOnScreen = slide1
        case slide3: viewOnScreen = slide2
        case slide4: viewOnScreen = slide3
        default: break
            
        }
        
    }
    @objc private func swipeFuncLeft(_ gesture: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            
            
            self.slide1.frame.origin.x -= self.sw
            self.slide2.frame.origin.x -= self.sw
            self.slide3.frame.origin.x -= self.sw
            self.slide4.frame.origin.x -= self.sw
            
        }
        
        switch viewOnScreen {
        case slide1: viewOnScreen = slide2
        case slide2: viewOnScreen = slide3
        case slide3: viewOnScreen = slide4
        case slide4: delay(bySeconds: 0.5) {
            self.playVideo()
            
            }
        default: break
     
            
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
        slide3.frame = CGRect(x: 40*sw/375 + 2*sw, y: 70*sh/667, width: 295*sw/375, height: 527*sh/667)
        slide3.image = #imageLiteral(resourceName: "Tutorial3")
        slide3.layer.cornerRadius = sw/50
        slide3.layer.masksToBounds = true
        view.addSubview(slide3)
    }
    private func setupSlide4() {
        slide4.frame = CGRect(x: 40*sw/375 + 3*sw, y: 70*sh/667, width: 295*sw/375, height: 527*sh/667)
        slide4.image = #imageLiteral(resourceName: "Tutorial4")
        slide4.layer.cornerRadius = sw/50
        slide4.layer.masksToBounds = true
        view.addSubview(slide4)
    }
    
}
