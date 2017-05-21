//
//  ViewController.swift
//  WordGame
//
//  Created by Aaron Halvorsen on 4/21/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit
import SwiftyStoreKit

class GameViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    let progressHUD = ProgressHUD(text: "Loading")
    var isFirstPlayFunc = true
    let myColor = CustomColor()
    let myBoard = Board.sharedInstance
    var pan = UIPanGestureRecognizer()
    var pan2 = UIPanGestureRecognizer()
    var tap = UITapGestureRecognizer()
    var doubleTap = UITapGestureRecognizer()
    var allTiles = [Tile]()
    var movingTile: Tile?
    var onDeckTiles = [Tile]()
    var wordTiles = [Tile]()
    var wordTilesPerpendicular = [Tile]()
    let pile = Tile()
    var pileOfTiles = 25 { didSet { pileOfTilesString = String(pileOfTiles); pile.text.text = pileOfTilesString } }
    var pileOfTilesString = "x15"
    var isNotSameTile = false
    let onDeckAlpha: CGFloat = 0.1
    var playButton = UIButton()
    var amountOfBoosts = Int() { didSet { LoadSaveCoreData.sharedInstance.saveBoost(amount: amountOfBoosts);
        
        if amountOfBoosts > 9 {
            boostIndicator.text = String(amountOfBoosts)
        } else {
            boostIndicator.text = "0" + String(amountOfBoosts)
        }
        
        }}
    var refillMode = false {didSet{
        if refillMode {
            view.removeGestureRecognizer(pan)
            view.addGestureRecognizer(pan2)
            
            for tile in allTiles {
                if tile.myWhereInPlay == .pile {
                    tile.topOfBlock.backgroundColor = self.myColor.purple
                    tile.text.textColor = .black
                    tile.alpha = 1.0
                }
                if tile.myWhereInPlay == .onDeck {
                    tile.topOfBlock.backgroundColor = self.myColor.teal
                    tile.text.textColor = .white
                    tile.alpha = 1.0
                }
                if tile.myWhereInPlay == .atBat {
                    tile.topOfBlock.backgroundColor = .white
                }
            }
            pile.alpha = 1.0
            
        } else {
            view.addGestureRecognizer(pan)
            view.removeGestureRecognizer(pan2)
            
            pile.alpha = onDeckAlpha
            for tile in allTiles {
                delay(bySeconds: 0.5) {
                    if tile.myWhereInPlay == .pile {
                        tile.topOfBlock.backgroundColor = self.myColor.teal
                        tile.text.textColor = .black
                        tile.alpha = self.onDeckAlpha
                    }
                    if tile.myWhereInPlay == .onDeck {
                        tile.topOfBlock.backgroundColor = self.myColor.purple
                        tile.text.textColor = .black
                        tile.alpha = self.onDeckAlpha
                    }
                    if tile.myWhereInPlay == .atBat {
                        tile.topOfBlock.backgroundColor = self.myColor.purple
                    }
                }
            }
        }}}
    var trash = UIImageView()
    var onTheBoard: Int = 0
    var duplicateLetterAmount2: Int = 0
    var duplicateLetter2 = "A"
    var duplicateLetterAmount: Int = 0
    var duplicateLetter = "A"
    var lengthOfWord: Int = 0
    var banner = UIImageView()
    var boostIndicator = UILabel()
    var isFirstLoading = false
    var startingNewGame = false
    var isWin = false
    var newGame = false
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isFirstLoading = !UserDefaults.standard.bool(forKey: "launchedWordGameBefore")
        myLoad()
        storeWholeState()
        LoadSaveCoreData.sharedInstance.saveState()
    }
    private func myLoad() {
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedWordGameBefore")
        let menuButton = UIButton()
        menuButton.frame = CGRect(x: 0, y: 0, width: 64*sw/375, height: 64*sw/375)
        menuButton.setImage(#imageLiteral(resourceName: "menu"), for: .normal)
        menuButton.addTarget(self, action: #selector(GameViewController.menuFunc(_:)), for: .touchUpInside)
        view.addSubview(menuButton)
        trash.frame = CGRect(x: 309*sw/375, y: 567*sh/667, width: 66*sw/375, height: 100*sh/667)
        trash.image = #imageLiteral(resourceName: "trash")
        view.addSubview(trash)
        view.backgroundColor = myColor.white245
        view.addSubview(myBoard)
        pan = UIPanGestureRecognizer(target: self, action: #selector(GameViewController.moveTile(_:)))
        view.addGestureRecognizer(pan)
       
        pan2 = UIPanGestureRecognizer(target: self, action: #selector(GameViewController.moveTile2(_:)))
        
        tap = UITapGestureRecognizer(target: self, action: #selector(GameViewController.tapTile(_:)))
        view.addGestureRecognizer(tap)
        pile.text.font = UIFont(name: "HelveticaNeue-Bold", size: 14*fontSizeMultiplier)
        pile.frame = CGRect(x: 13*sw/375, y: 616*sh/667, width: 34*sw/375, height: 34*sw/375)
        pile.myWhereInPlay = .pile
        view.addSubview(pile)
        pile.text.text = pileOfTilesString
        allTiles.append(pile)
        pile.alpha = onDeckAlpha
        if launchedBefore  {
            LoadSaveCoreData.sharedInstance.loadState()
        }
        addTilesToBoard()
        startGameWithTilesOnBoard(difficulty: .hard)
        playButton.frame = CGRect(x: sw/4, y: 45*sh/667, width: sw/2, height: 69*sh/667)
        playButton.setImage(#imageLiteral(resourceName: "play"),for: .normal)
        playButton.backgroundColor = myColor.white245
        playButton.addTarget(self, action: #selector(GameViewController.playFunc(_:)), for: .touchUpInside)
        playButton.setTitleColor(myColor.purple, for: .normal)
        view.addSubview(playButton)
        
        myBoard.delegate = self
        self.myBoard.showsHorizontalScrollIndicator = false
        self.myBoard.showsVerticalScrollIndicator = false
        doubleTap.numberOfTapsRequired = 2
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(GameViewController.doubleTapFunc(_:)))
        view.addGestureRecognizer(doubleTap)
        tap.require(toFail: doubleTap)
        doubleTap.numberOfTapsRequired = 2
        delay(bySeconds: 1.0){
            // self.view.alpha = 0.2
            
            if launchedBefore  {
                print("Not first launch.")
                
            } else {
                self.performSegue(withIdentifier: "fromGameToTutorial", sender: self)
                UserDefaults.standard.set(true, forKey: "launchedWordGameBefore")
            }
            
        }
        
        banner.image = #imageLiteral(resourceName: "rocket")
        banner.frame = CGRect(x: 276*sw/375, y: 0, width: 99*sw/375, height: 70*sw/375)
        banner.alpha = 1.0
        view.addSubview(banner)
        
        boostIndicator = UILabel(frame: CGRect(x: 290*sw/375, y: 25*sh/667, width: 30*sw/375, height: 25*sw/667))
        if amountOfBoosts < 10 {
            boostIndicator.text = "0" + String(amountOfBoosts)
        } else {
            boostIndicator.text = String(amountOfBoosts)
        }
        boostIndicator.font = UIFont(name: "Helvetica-Bold", size: 19*fontSizeMultiplier)
        boostIndicator.textColor = myColor.teal
        boostIndicator.textAlignment = .left
        
        view.addSubview(boostIndicator)
        
        
    }
    var myMenu = MenuViewController()
    override func viewWillAppear(_ animated: Bool) {
        
        doubleTap.numberOfTapsRequired = 2
        let a = LoadSaveCoreData.sharedInstance.loadBoost()
        if a != nil {
            amountOfBoosts = a!
        } else {
            amountOfBoosts = 1
        }
        if newGame {
            isWin = false
            Set1.winState = false
            restart()
        }
        if Set1.winState {
            isWin = true
            
            alreadyWinSequence()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // winSequence()
    }
    
    
    private func bannerFunc() {
        if amountOfBoosts > 0 {
            boost()
            amountOfBoosts -= 1
            
        } else {
            IAP()
        }
    }
    private func IAP() {
        let alert = UIAlertController(title: "Boost", message: "Buy 3 Boosts for $.99", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default) { (action: UIAlertAction!) in
            self.purchase(productId: "com.wordsWithNoFriends.boosts")
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        //handle an action...
        
        
        
    }
    
    @objc private func menuFunc(_ button: UIButton) {
        // self.present(myMenu, animated: true, completion: nil)
        // self.presentModalViewController(myMenu, animated: true)
        performSegue(withIdentifier: "fromGameToMenu", sender: self)
    }
    func backFromCamera() {
        print("Back from camera")
    }
    
    func leave() {
        dismiss(animated: true, completion: nil)
    }
    
    private func findTheString(callback: (_ word: String?, _ rowWord: Bool, _ tilesInPlay: [Tile]) -> Void) {
        var tilesInPlay = [Tile]()
        for tile in allTiles {
            if tile.myWhereInPlay == .board && tile.isLockedInPlace == false {
                tilesInPlay.append(tile)
            }
        }
        guard tilesInPlay.count > 0 else {return}
        let row = tilesInPlay[0].row!
        let column = tilesInPlay[0].column!
        var isSameRow = true
        var isSameColumn = true
        var smallestRow = 16
        var smallestColumn = 16
        var bool1 = false
        var bool2 = false
        var bool3 = false
        var word = String()
        for tile in tilesInPlay {
            if tile.row! < smallestRow {
                smallestRow = tile.row!
            }
            if tile.column! < smallestColumn {
                smallestColumn = tile.column!
            }
            if row != tile.row {
                isSameRow = false
            }
            if column != tile.column {
                isSameColumn = false
            }
        }
        for _ in 0...6 {
            for tile in allTiles {
                if tile.isStarterBlock || tile.isLockedInPlace {
                    
                    if isSameRow {
                        
                        if tile.row == smallestRow && tile.column == smallestColumn - 1 {
                            
                            smallestColumn -= 1
                            tilesInPlay.append(tile)
                        }
                    } else if isSameColumn {
                        
                        if tile.row == smallestRow - 1 && tile.column == smallestColumn {
                            
                            smallestRow -= 1
                            tilesInPlay.append(tile)
                        }
                    }
                    
                    
                    
                }
            }
        }
        
        if wordTiles.count == 1 {
            
            for tile in allTiles {
                if tile.isLockedInPlace == true && tile.row == wordTiles[0].row! - 1 {
                    isSameRow = false
                    isSameColumn = true
                }
                if tile.isLockedInPlace == true && tile.column == wordTiles[0].column! - 1 {
                    isSameRow = true
                    isSameColumn = false
                }
                if tile.isLockedInPlace == true && tile.row == wordTiles[0].row! + 1 {
                    isSameRow = false
                    isSameColumn = true
                }
                if tile.isLockedInPlace == true && tile.column == wordTiles[0].column! + 1 {
                    isSameRow = true
                    isSameColumn = false
                }
            }
        }
        
        if !isSameColumn && !isSameRow {
            callback(nil, true, tilesInPlay)
        }
        if isSameRow {
            
            (bool1,bool2,bool3) = checkIfThereIsPriorTileInSameRow(row: smallestRow, column: smallestColumn)
            
            if bool1 == true {
                smallestColumn -= 1
                if bool2 == true {
                    smallestColumn -= 1
                    if bool3 == true {
                        smallestColumn -= 1
                    }                }
            }
            var dontQuit = true
            while dontQuit {
                var count = 1
                outerLoop:  for tile in allTiles {
                    
                    if tile.row != nil && tile.myWhereInPlay == .board {
                        
                        
                        if tile.row! == smallestRow && tile.column! == smallestColumn {
                            
                            
                            word += tile.mySymbol.rawValue
                     
                            wordTiles.append(tile)
                            smallestColumn += 1
                            break outerLoop
                        } else if allTiles.count == count {
                            
                            
                            dontQuit = false
                            callback(word, true, tilesInPlay)
                        }
                        
                    } else if allTiles.count == count {
                        dontQuit = false
                        callback(word, true, tilesInPlay)
                    }
                    count += 1
                }
            }
        } else if isSameColumn {
            
            (bool1,bool2,bool3) = checkIfThereIsPriorTileInSameColumn(row: smallestRow, column: smallestColumn)
            if bool1 == true {
                smallestColumn -= 1
                if bool2 == true {
                    smallestColumn -= 1
                    if bool3 == true {
                        smallestColumn -= 1
                    }
                }
            }
            var dontQuit = true
            while dontQuit {
                
                var count = 1
                outerLoop: for tile in allTiles {
                    if tile.row != nil && tile.myWhereInPlay == .board {
                        if tile.row! == smallestRow && tile.column! == smallestColumn {
                            word += tile.mySymbol.rawValue
                         
                            wordTiles.append(tile)
                            
                            smallestRow += 1
                            break outerLoop
                        } else if allTiles.count == count {
                            dontQuit = false
                            callback(word, false, tilesInPlay)
                        }
                        
                    } else if allTiles.count == count {
                        dontQuit = false
                        callback(word, false, tilesInPlay)
                    }
                    count += 1
                }
            }
        }
        
    }
    
    private func checkIfThereIsPriorTileInSameRow(row: Int, column: Int) -> (Bool,Bool,Bool) {
        var one = false
        var two = false
        var three = false
        for tile in allTiles {
            if tile.column != nil {
                
                if tile.column! + 1 == column && tile.row! == row {
                    one = true
                }
                if tile.column! + 2 == column && tile.row! == row {
                    two = true
                }
                if tile.column! + 3 == column && tile.row! == row {
                    three = true
                }
            }
        }
        return (one,two,three)
    }
    
    private func checkIfThereIsPriorTileInSameColumn(row: Int, column: Int) -> (Bool,Bool,Bool) {
        var one = false
        var two = false
        var three = false
        for tile in allTiles {
            if tile.row != nil {
                if tile.row! + 1 == row && tile.column! == column {
                    one = true
                }
                if tile.row! + 2 == row && tile.column! == column {
                    two = true
                }
                if tile.row! + 3 == row && tile.column! == column {
                    three = true
                }
            }
        }
        return (one,two,three)
    }
    
    var isMainWordReal = false
    @objc private func playFunc(_ button: UIButton) {
        isMainWordReal = false
        let bonusTiles = ["Q","X","J","Z","W"]
        guard isFirstPlayFunc == true else {isFirstPlayFunc = true; return}
        isFirstPlayFunc = false
        for tile in allTiles {
            if tile.myWhereInPlay == .board {

            }
        }
        findTheString() { (word,isRowWord,tilesInPlay) -> Void in
            if let w = word {
           
                lengthOfWord = wordTiles.count
                var lettersList = [String]()
                var repeat1 = 1
                var repeat2 = 1
                var repeat1Letter = String()
                var repeat2Letter = String()
                duplicateLetterAmount = 0
                duplicateLetterAmount2 = 0
                for tile in wordTiles {
                    if lettersList.contains(tile.mySymbol.rawValue) {
                        if repeat1 == 1 {
                            repeat1 += 1
                            repeat1Letter = tile.mySymbol.rawValue
                        } else if repeat2 == 1 {
                            repeat2 += 1
                            repeat2Letter = tile.mySymbol.rawValue
                        } else if tile.mySymbol.rawValue == repeat1Letter {
                            repeat1 += 1
                        } else if tile.mySymbol.rawValue == repeat2Letter {
                            repeat2 += 1
                        }
                    } else {
                        lettersList.append(tile.mySymbol.rawValue)
                    }
                }
                if repeat1 > 1 {
                    duplicateLetter = repeat1Letter
                    duplicateLetterAmount = repeat1
             
                }
                if repeat2 > 1 {
                    duplicateLetter2 = repeat2Letter
                    duplicateLetterAmount2 = repeat2
                }
                
                let everythingChecksOutPerpendicular = perpendicularWords(isRowWord: isRowWord, tilesInPlay: tilesInPlay)
                myBoard.zoomOut() { () -> Void in
                    for tile in allTiles {
                        dropTileWhereItBelongs(tile: tile)
                    }
                    
                    refreshSizes()
                }
                
                guard isReal(word: w.lowercased()) != nil else {wordTiles.removeAll(); return}
                if isReal(word: w.lowercased())! && everythingChecksOutPerpendicular {
                    
                    for i in 0..<wordTiles.count {
                        wordTiles[i].isBuildable = true
                        delay(bySeconds: 0.2*Double(i)+0.6) {
                            
                            self.wordTiles[i].isLockedInPlace = true
                            if self.wordTiles[i].isStarterBlock {
                                self.wordTiles[i].isStarterBlock = false
                                self.wordTiles[i].topOfBlock.backgroundColor = self.myColor.teal
                                self.wordTiles[i].text.textColor = .white
                                
                            }
                            if bonusTiles.contains(self.wordTiles[i].mySymbol.rawValue) {
                                self.bonusPile(character: self.wordTiles[i].mySymbol.rawValue)
                            }
                            if i == self.wordTiles.count - 1 {
                                                                if self.lengthOfWord > 4 {
                                    self.isMainWordReal = true
                                    self.longWordBonus(length: self.lengthOfWord)
                                }
                                self.lengthOfWord = 0
                                
                                
                                self.wordTiles.removeAll()
                                self.wordTilesPerpendicular.removeAll()
                                self.onTheBoard = 0
                                self.isFirstPlayFunc = true
                                self.lockTilesAndRefillRack()
                                
                                if self.duplicateLetterAmount > 1 {
                                    self.multipleLetterBonus(letter: self.duplicateLetter, amount: self.duplicateLetterAmount)
                                }
                                self.delay(bySeconds: 0.3) {
                                    if self.duplicateLetterAmount2 > 1 {
                                        self.multipleLetterBonus(letter: self.duplicateLetter2, amount: self.duplicateLetterAmount2)
                                    }
                                }
                                
                                self.duplicateLetterAmount = 0
                                
                                self.duplicateLetterAmount2 = 0
                                
                                self.isWin = true
                                for tile in self.allTiles {
                                    if tile.isStarterBlock {
                                        self.isWin = false
                                    }
                                }
                                if self.isWin {
                             
                                    self.winSequence()
                                }
                                self.storeWholeState()
                                LoadSaveCoreData.sharedInstance.saveState()
                            }
                            
                        }
                        
                    }
                    
                    
                } else {
                    wordTiles.removeAll()
                    wordAlert(word: w)
                }
                
            } else {
                wordTiles.removeAll()
                isFirstPlayFunc = true
                let alert = UIAlertController(title: "Retry", message: "Can only spell one word at a time", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        isFirstPlayFunc = true
        
    }
    private func boost() {
        for i in 0...14 {
            delay(bySeconds: 0.2*Double(i)+0.4) {
                self.bonusPile()
            }
        }
    }
    private func winSequence() {
        Set1.wins += 1
        Set1.winState = true
        
        for i in 0...10 {
            delay(bySeconds: 1.0*Double(i)) {
                for tile in self.allTiles {
                    tile.topOfBlock.backgroundColor = UIColor(colorLiteralRed: Float(drand48()), green: Float(drand48()), blue: Float(drand48()), alpha: 1.0)
                    tile.text.textColor = .black
                    //      win.textColor = UIColor(colorLiteralRed: Float(drand48()), green: Float(drand48()), blue: Float(drand48()), alpha: 1.0)
                }
            }
            
            
        }
  
        view.removeGestureRecognizer(tap)
        view.removeGestureRecognizer(pan2)
        view.removeGestureRecognizer(pan)
        view.removeGestureRecognizer(doubleTap)
    }
    
    private func alreadyWinSequence() {
        
        for i in 0...2 {
            delay(bySeconds: 1.0*Double(i)) {
                for tile in self.allTiles {
                    tile.topOfBlock.backgroundColor = UIColor(colorLiteralRed: Float(drand48()), green: Float(drand48()), blue: Float(drand48()), alpha: 1.0)
                    tile.text.textColor = UIColor(colorLiteralRed: Float(drand48()), green: Float(drand48()), blue: Float(drand48()), alpha: 1.0)
                    //        win.textColor = UIColor(colorLiteralRed: Float(drand48()), green: Float(drand48()), blue: Float(drand48()), alpha: 1.0)
                }
            }
        }
 
        view.removeGestureRecognizer(tap)
        view.removeGestureRecognizer(pan)
        view.removeGestureRecognizer(pan2)
        view.removeGestureRecognizer(doubleTap)
    }
    
    private func bonusPile(character: String? = nil) {
        
        pileOfTiles += 1
        let bonus = UILabel(frame: CGRect(x: 22*sw/375, y: 625*sh/667, width: 50*sw/375, height: 16*sw/375))
        bonus.font = UIFont(name: "ArialRoundedMTBold", size: 14*fontSizeMultiplier)
        bonus.textAlignment = .left
        if character != nil { bonus.text = "+1" + character! } else { bonus.text = "+1" }
        view.addSubview(bonus)
        UIView.animate(withDuration: 2.5) {
            bonus.frame.origin = CGPoint(x: 22*self.sw/375, y: 550*self.sh/667)
            bonus.font.withSize(20*self.fontSizeMultiplier)
            bonus.alpha = 0.0
        }
        delay(bySeconds: 2.5) {
            bonus.removeFromSuperview()
        }
    }
    private func bonusOnDeck(x: CGFloat, y: CGFloat, text: String = "+1") {
        
        let bonus = UILabel(frame: CGRect(x: x, y: y, width: 50*sw/375, height: 16*sw/375))
        bonus.font = UIFont(name: "ArialRoundedMTBold", size: 14*fontSizeMultiplier)
        bonus.text = text
        view.addSubview(bonus)
        UIView.animate(withDuration: 2.5) {
            bonus.frame.origin = CGPoint(x: x, y: y - 75*self.sh/667)
            bonus.font.withSize(20*self.fontSizeMultiplier)
            bonus.alpha = 0.0
        }
        delay(bySeconds: 2.5) {
            bonus.removeFromSuperview()
        }
    }
    
    private func multipleLetterBonus(letter: String, amount: Int) {
        switch amount {
        case 2:
            
            
            if self.onDeckTiles.count < 10 {
                let tile = Tile()
                self.onDeckTiles.append(tile)
                tile.mySymbol = self.pickRandomLetter()
                tile.onDeckTileOrder = self.onDeckTiles.count - 1
                tile.myWhereInPlay = .onDeck
                tile.topOfBlock.backgroundColor = self.myColor.teal
                tile.text.textColor = .white
                self.view.addSubview(tile)
                self.allTiles.append(tile)
                for tile1 in self.onDeckTiles {
                    self.dropTileWhereItBelongs(tile: tile1)
                    if tile == tile1 {
                        self.bonusOnDeck(x: tile.frame.origin.x, y: tile.frame.origin.y, text: String(amount) + " " + letter + "'s")
                    }
                }
            } else {
                self.bonusPile()
            }
            
            
            
        case 3,4,5,6,7:
            for i in 0..<2 {
                delay(bySeconds: 0.2*Double(i)+0.4) {
                    if self.onDeckTiles.count < 10 {
                        let tile = Tile()
                        self.onDeckTiles.append(tile)
                        tile.mySymbol = self.pickRandomLetter()
                        tile.onDeckTileOrder = self.onDeckTiles.count - 1
                        tile.myWhereInPlay = .onDeck
                        tile.topOfBlock.backgroundColor = self.myColor.teal
                        tile.text.textColor = .white
                        self.view.addSubview(tile)
                        self.allTiles.append(tile)
                        for tile1 in self.onDeckTiles {
                            self.dropTileWhereItBelongs(tile: tile1)
                            if tile == tile1 {
                                self.bonusOnDeck(x: tile.frame.origin.x, y: tile.frame.origin.y, text: String(amount) + " " + letter + "'s")
                            }
                        }
                    } else {
                        self.bonusPile()
                    }
                }
            }
        default:
            break
        }
    }
    
    private func longWordBonus(length: Int) {
        
        var pileBonus = 0
        var flippedBonus = 0
        switch length {
        case 5:
            pileBonus = 3
            flippedBonus = 0
        case 6:
            pileBonus = 4
            flippedBonus = 1
        case 7:
            pileBonus = 5
            flippedBonus = 2
        case 8:
            pileBonus = 5
            flippedBonus = 2
        case 9:
            pileBonus = 5
            flippedBonus = 2
        case 10,11,12,13,14,15:
            pileBonus = 6
            flippedBonus = 2
            amountOfBoosts += 1
        default:
            break
        }
        for i in 0..<pileBonus {
            delay(bySeconds: 0.2*Double(i)+0.4) {
                self.bonusPile()
            }
        }
        
        for i in 0..<flippedBonus {
            delay(bySeconds: 0.2*Double(i)+0.4) {
                if self.onDeckTiles.count < 10 {
                    let tile = Tile()
                    self.onDeckTiles.append(tile)
                    tile.mySymbol = self.pickRandomLetter()
                    tile.onDeckTileOrder = self.onDeckTiles.count - 1
                    tile.myWhereInPlay = .onDeck
                    tile.topOfBlock.backgroundColor = self.myColor.teal
                    tile.text.textColor = .white
                    self.view.addSubview(tile)
                    self.allTiles.append(tile)
                    for tile1 in self.onDeckTiles {
                        self.dropTileWhereItBelongs(tile: tile1)
                        if tile == tile1 {
                            self.bonusOnDeck(x: tile.frame.origin.x, y: tile.frame.origin.y)
                        }
                    }
                } else {
                    self.bonusPile()
                }
            }
        }
        
    }
    
    private func wordAlert(word: String) {
        wordTiles.removeAll()
        wordTilesPerpendicular.removeAll()
        isFirstPlayFunc = true
        let alert = UIAlertController(title: word.uppercased(), message: "Not a word", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func perpendicularWords(isRowWord: Bool, tilesInPlay: [Tile]) -> Bool {
        var everythingChecksOut = true
        var indexesOfWords = [Int]()
        var smallestRow = 16
        var smallestColumn = 16
        
        
        switch isRowWord {
            
        case true:
            for tile in tilesInPlay {
                if tile.slotsIndex! - 1 > -1 {
                    if myBoard.slots[tile.slotsIndex! - 1].isOccupied {
                        indexesOfWords.append(tile.slotsIndex!)
                    }
                }
                if tile.slotsIndex! + 1 < 225 {
                    if myBoard.slots[tile.slotsIndex! + 1].isOccupied{
                        indexesOfWords.append(tile.slotsIndex!)
                    }
                }
                
            }
            for index in indexesOfWords {
                
                smallestRow = myBoard.slots[index].row
                smallestColumn = myBoard.slots[index].column
                var isKeepGoing = true
                while isKeepGoing {
                    isKeepGoing = false
                    loop: for tile in allTiles {
                        
                        if tile.myWhereInPlay == .board && myBoard.slots[index].column == tile.column! && tile.row! + 1 == smallestRow {
                            
                            smallestRow = tile.row!
                            isKeepGoing = true
                            break loop
                        }
                    }
                    
                }
                var word = String()
                var dontQuit = true
                var perpedicularWordHasNewLetter = false
                var isAtLeastOneNewTile = false
                while dontQuit {
                    var count = 1
                    
                    outerLoop:  for tile in allTiles {
                        
                        if tile.column != nil && tile.myWhereInPlay == .board {
                            
                            
                            if tile.column! == smallestColumn && tile.row! == smallestRow {
                                
                                if !tile.isBuildable { perpedicularWordHasNewLetter = true }
                                if tilesInPlay.contains(tile) {
                                    isAtLeastOneNewTile = true
                                }
                                word += tile.mySymbol.rawValue
                                wordTilesPerpendicular.append(tile)
                                
                                smallestRow += 1
                                break outerLoop
                            } else if allTiles.count == count {
                                
                                
                                dontQuit = false
                                if !isReal2(word: word.lowercased()){
                                    everythingChecksOut = false
                                    wordAlert(word: word)
                                } else {
                                    if perpedicularWordHasNewLetter && word.characters.count > 4 && isAtLeastOneNewTile {
                                        delay(bySeconds: 0.2) {
                                            if self.isMainWordReal {
                                                self.longWordBonus(length: word.characters.count)
                                            }
                                        }
                                    }
                                }
                            }
                            
                        } else if allTiles.count == count {
                            dontQuit = false
                            if !isReal2(word: word.lowercased()) {
                                everythingChecksOut = false
                                wordAlert(word: word)
                            } else {
                                if perpedicularWordHasNewLetter && word.characters.count > 4 && isAtLeastOneNewTile {
                                    delay(bySeconds: 0.2) {
                                        if self.isMainWordReal {
                                            self.longWordBonus(length: word.characters.count)
                                        }
                                    }
                                }
                            }
                            
                        }
                        count += 1
                    }
                }
                
                
            }
            
        case false:
            for tile in tilesInPlay {
                
                if tile.slotsIndex! - 15 > -1 {
                    if myBoard.slots[tile.slotsIndex! - 15].isOccupied {
                        indexesOfWords.append(tile.slotsIndex!)
                        
                    }
                }
                if tile.slotsIndex! + 15 < 225 {
                    if myBoard.slots[tile.slotsIndex! + 15].isOccupied {
                        indexesOfWords.append(tile.slotsIndex!)
                        
                    }
                }
            }
            for index in indexesOfWords {
                
                smallestRow = myBoard.slots[index].row
                smallestColumn = myBoard.slots[index].column
                var isKeepGoing = true
                while isKeepGoing {
                    isKeepGoing = false
                    loop: for tile in allTiles {
                        
                        
                        if tile.myWhereInPlay == .board && myBoard.slots[index].row == tile.row! && tile.column! + 1 == smallestColumn {
                            
                            smallestColumn = tile.column!
                            isKeepGoing = true
                            break loop
                        }
                    }
                    
                }
                
                var dontQuit = true
                var word = String()
                var perpendicularWordHasNewLetter = false
                while dontQuit {
                    var count = 1
                    
                    outerLoop:  for tile in allTiles {
                        
                        if tile.row != nil && tile.myWhereInPlay == .board {
                            
                            
                            if tile.row! == smallestRow && tile.column! == smallestColumn {
                                
                                if !tile.isBuildable { perpendicularWordHasNewLetter = true }
                                word += tile.mySymbol.rawValue
                                wordTilesPerpendicular.append(tile)
                                
                                smallestColumn += 1
                                break outerLoop
                            } else if allTiles.count == count {
                                
                                
                                dontQuit = false
                                if !isReal2(word: word.lowercased()) {
                                    everythingChecksOut = false
                                    wordAlert(word: word)
                                } else {
                                    if perpendicularWordHasNewLetter && word.characters.count > 4 {
                                        delay(bySeconds: 0.2) {
                                            if self.isMainWordReal {
                                                self.longWordBonus(length: word.characters.count)
                                            }
                                        }
                                    }
                                }
                            }
                            
                        } else if allTiles.count == count {
                            dontQuit = false
                            if !isReal2(word: word.lowercased()) {
                                everythingChecksOut = false
                                wordAlert(word: word)
                            } else {
                                if perpendicularWordHasNewLetter && word.characters.count > 4 {
                                    delay(bySeconds: 0.2) {
                                        if self.isMainWordReal {
                                            self.longWordBonus(length: word.characters.count)
                                        }
                                    }
                                }
                            }
                            
                        }
                        count += 1
                    }
                }
                
                
            }
        }
        
        return everythingChecksOut
    }
    
    
    
    private func rearrangeAtBat() {
        var container = [Int]()
        var taken = [Int]()
        for tile in allTiles {
            if tile.myWhereInPlay == .atBat {
                container.append(tile.atBatTileOrder!)
            }
        }
        for tile in allTiles {
            if tile.myWhereInPlay == .atBat {
                if taken.contains(tile.atBatTileOrder!) {
                    for i in 0...6 {
                        if !container.contains(i) {
                            tile.atBatTileOrder = i
                            container.append(tile.atBatTileOrder!)
                            dropTileWhereItBelongs(tile: tile)
                        }
                    }
                }
                taken.append(tile.atBatTileOrder!)
            }
        }
    }
    
    private func lockTilesAndRefillRack() {
        
        refillMode = true
    }
    
    
    func isReal(word: String) -> Bool? {
        var isWordBuildable = false
        var tilesInPlay = [Tile]()
        for tile in allTiles {
            if tile.myWhereInPlay == .board && tile.isLockedInPlace == false {
                tilesInPlay.append(tile)
            }
        }
        
        for tile in allTiles {
            if tile.isBuildable {

                for tile2 in tilesInPlay {
                    
                    let test1: Bool = tile2.row! - 1 == tile.row! && tile2.column! == tile.column!
                    let test2: Bool = tile2.row! + 1 == tile.row! && tile2.column! == tile.column!
                    let test3: Bool = tile2.column! - 1 == tile.column! && tile2.row! == tile.row!
                    let test4: Bool = tile2.column! + 1 == tile.column! && tile2.row! == tile.row!
                    if test1 || test2 || test3 || test4 { isWordBuildable = true }
                }
            }
        }
        
        guard isWordBuildable == true else {
            //          var isFirstPlayFunc = true
            let alert = UIAlertController(title: word.uppercased(), message: "Must build off teal tiles", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return nil
        }
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.characters.count)
        let wordRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        if word == "fe" || word == "ki" || word == "oi" || word == "qi" || word == "za" || word == "qis" || word == "zas" || word == "fes" || word == "kis" {
            return true
        }
        
        if wordRange.location == NSNotFound {

            
            for tile in wordTilesPerpendicular {
                if !wordTiles.contains(tile) {
                    wordTiles.append(tile)
                }
            }
        
        }
        
        return wordRange.location == NSNotFound
    }
    
    func isReal2(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        if word == "fe" || word == "ki" || word == "oi" || word == "qi" || word == "za" || word == "qis" || word == "zas" || word == "fes" || word == "kis" {
            return true
        }
        
        return misspelledRange.location == NSNotFound
    }
    
    private func reOrderAtBat() {
        var here = [Int]()
        for tile in allTiles {
            if tile.myWhereInPlay == .atBat && tile != movingTile {
                if here.contains(tile.atBatTileOrder!) {
                    tile.atBatTileOrder! += 1
                    if tile.atBatTileOrder == 7 {
                        tile.atBatTileOrder = 0
                    }
                }
                here.append(tile.atBatTileOrder!)
                dropTileWhereItBelongs(tile: tile)
            }
            
        }
        
    }
    
    func addTilesToBoard() {
        if isFirstLoading || startingNewGame {
            for i in 0...4 {
                let tile = Tile()
                tile.mySymbol = pickRandomLetter()
                tile.onDeckTileOrder = i
                tile.myWhereInPlay = .onDeck
                tile.alpha = onDeckAlpha
                view.addSubview(tile)
                allTiles.append(tile)
                onDeckTiles.append(tile)
            }
            for tile in onDeckTiles {
                dropTileWhereItBelongs(tile: tile)
            }
            for i in 0...6 {
                let tile = Tile()
                tile.mySymbol = pickRandomLetter()
                tile.atBatTileOrder = i
                
                tile.myWhereInPlay = .atBat
                view.addSubview(tile)
                allTiles.append(tile)
                dropTileWhereItBelongs(tile: tile)
            }
        } else {
            for i in 0..<Set1.onDeckRawValue.count {
                let tile = Tile()
                tile.mySymbol = whatsMySymbol(character: Set1.onDeckRawValue[i])
                tile.onDeckTileOrder = i
                tile.myWhereInPlay = .onDeck
                tile.alpha = onDeckAlpha
                view.addSubview(tile)
                allTiles.append(tile)
                onDeckTiles.append(tile)
                
            }
            for tile in onDeckTiles {
                dropTileWhereItBelongs(tile: tile)
            }
            for i in 0..<Set1.atBatRawValue.count {
                let tile = Tile()
                tile.mySymbol = whatsMySymbol(character: Set1.atBatRawValue[i])
                tile.myWhereInPlay = .atBat
                tile.atBatTileOrder = i
                view.addSubview(tile)
                allTiles.append(tile)
                dropTileWhereItBelongs(tile: tile)
            }
            if Set1.atBatRawValue.count < 7 {
                refillMode = true
            }
        }
        
    }
    enum Difficulty {
        case easy,medium,hard
    }
    
    func whileFunction(rowLow: Int, rowHigh: Int, randomStartSlotIndex: Int, randomEndSlotIndex: Int, callback: (Int) -> Void) {
        var oneIndex = 500
        var oneIndexRow = -1
        
        while oneIndexRow < rowLow || oneIndexRow > rowHigh || oneIndex == randomStartSlotIndex || oneIndex == randomEndSlotIndex || oneIndex == randomStartSlotIndex + 1 || oneIndex == randomStartSlotIndex - 1 || oneIndex == randomStartSlotIndex + 15 || oneIndex == randomEndSlotIndex - 1 || oneIndex == randomEndSlotIndex + 1 || oneIndex == randomEndSlotIndex - 15 {
            
            oneIndex = Int(arc4random_uniform(224))
            
            oneIndexRow = myBoard.slots[oneIndex].row
        }
        
        callback(oneIndex)   // call the callback function
    }
    
    
    
    private func startGameWithTilesOnBoard(difficulty: Difficulty) {
        if isFirstLoading || startingNewGame {
            let randomStartSlotIndex = Int(arc4random_uniform(14))
            let randomEndSlotIndex = Int(arc4random_uniform(14) + 210)
            for i in 0...1 {
                let tile = Tile()
                tile.mySymbol = pickRandomLetter()
                tile.myWhereInPlay = .board
                if i == 1 {
                    tile.isStarterBlock = true
                } else {
                    tile.isBuildable = true
                }
                if i == 0 {
                    let slot = myBoard.slots[randomStartSlotIndex]
                    tile.slotsIndex = randomStartSlotIndex
                    slot.isOccupied = true
                    slot.isPermanentlyOccupied = true
                    slot.isOccupiedFromStart = true
                    tile.row = slot.row
                    tile.column = slot.column
                } else {
                    let slot = myBoard.slots[randomEndSlotIndex]
                    tile.slotsIndex = randomEndSlotIndex
                    slot.isOccupied = true
                    slot.isPermanentlyOccupied = true
                    slot.isOccupiedFromStart = true
                    tile.row = slot.row
                    tile.column = slot.column
                }
                tile.isLockedInPlace = true
                view.addSubview(tile)
                allTiles.append(tile)
                dropTileWhereItBelongs(tile: tile)
            }
            
            switch difficulty {
            case .easy:
                break
                
            case .medium:
                let rowStart = myBoard.slots[randomStartSlotIndex].row
                let rowEnd = myBoard.slots[randomEndSlotIndex].row
                var rowLow = Int()
                var rowHigh = Int()
                //            var oneIndexRow = 20
                //            var oneIndex = -1
                if rowEnd > rowStart {
                    rowHigh = rowEnd; rowLow = rowStart
                } else {
                    rowHigh = rowStart; rowLow = rowEnd
                }
                whileFunction(rowLow: rowLow, rowHigh: rowHigh, randomStartSlotIndex: randomStartSlotIndex, randomEndSlotIndex: randomEndSlotIndex) { (oneIndex) -> Void in
                    
                    let tile = Tile()
                    tile.isStarterBlock = true
                    tile.mySymbol = pickRandomLetter()
                    tile.myWhereInPlay = .board
                    tile.isLockedInPlace = true
                    let slot = myBoard.slots[oneIndex]
                    tile.slotsIndex = oneIndex
                    slot.isOccupied = true
                    slot.isPermanentlyOccupied = true
                    slot.isOccupiedFromStart = true
                    tile.row = slot.row
                    tile.column = slot.column
                    
                    view.addSubview(tile)
                    allTiles.append(tile)
                    dropTileWhereItBelongs(tile: tile)
                }
                
            case .hard:
                
                for _ in 0...4 {
                    whileFunction(rowLow: 2, rowHigh: 13, randomStartSlotIndex: randomStartSlotIndex, randomEndSlotIndex: randomEndSlotIndex) { (oneIndex) -> Void in
                        var _oneIndex = oneIndex
                        if oneIndex - 15 < 0 {_oneIndex += 15}
                        if oneIndex + 15 > 224 {_oneIndex -= 15}
                        
                        if !myBoard.slots[_oneIndex - 1].isOccupied && !myBoard.slots[_oneIndex + 1].isOccupied && !myBoard.slots[_oneIndex - 15].isOccupied && !myBoard.slots[_oneIndex + 15].isOccupied && !myBoard.slots[_oneIndex].isOccupied {
                            let tile = Tile()
                            tile.isStarterBlock = true
                            
                            tile.mySymbol = pickRandomLetter()
                            tile.myWhereInPlay = .board
                            tile.isLockedInPlace = true
                            let slot = myBoard.slots[_oneIndex]
                            tile.slotsIndex = _oneIndex
                            
                            slot.isOccupied = true
                            slot.isPermanentlyOccupied = true
                            slot.isOccupiedFromStart = true
                            tile.row = slot.row
                            tile.column = slot.column
                            
                            view.addSubview(tile)
                            
                            
                            dropTileWhereItBelongs(tile: tile)
                            
                            allTiles.append(tile)
                        }
                    }
                }
            }
        } else {
            for i in 0..<Set1.indexBuildable.count {
                let tile = Tile()
                tile.mySymbol = whatsMySymbol(character: Set1.buildableRawValue[i])
                tile.myWhereInPlay = .board
                tile.isLockedInPlace = true
                tile.isBuildable = true
                let slot = myBoard.slots[Set1.indexBuildable[i]]
                tile.slotsIndex = Set1.indexBuildable[i]
                slot.isOccupied = true
                slot.isPermanentlyOccupied = true
                tile.row = slot.row
                tile.column = slot.column
                view.addSubview(tile)
                
                dropTileWhereItBelongs(tile: tile)
                allTiles.append(tile)
                
            }
            
            for i in 0..<Set1.indexStart.count {
                let tile = Tile()
                tile.isStarterBlock = true
                
                tile.mySymbol = whatsMySymbol(character: Set1.startRawValue[i])
                tile.myWhereInPlay = .board
                //tile.isLockedInPlace = true
                //tile.isBuildable = true
                let slot = myBoard.slots[Set1.indexStart[i]]
                tile.slotsIndex = Set1.indexStart[i]
                tile.isLockedInPlace = true
                tile.topOfBlock.backgroundColor = myColor.purple
                tile.text.textColor = .black
                slot.isOccupied = true
                slot.isPermanentlyOccupied = true
                tile.row = slot.row
                tile.column = slot.column
                view.addSubview(tile)
                
                dropTileWhereItBelongs(tile: tile)
                allTiles.append(tile)
                
            }
            pileOfTiles = Set1.pileAmount
            
        }
        storeWholeState()
    }
    var once = true
    @objc private func tapTile(_ gesture: UITapGestureRecognizer) {
        once = true
        switch refillMode {
        case false:
            for tile in allTiles {
                if !myBoard.frame.contains(gesture.location(in: view)) && once {
                    once = false
                    if tile.frame.contains(gesture.location(in: view)) && !tile.isLockedInPlace && tile.myWhereInPlay == .atBat {
                        movingTile = tile
                    }
                } else {
                    if tile.frame.contains(gesture.location(in: myBoard)) && !tile.isLockedInPlace && tile.myWhereInPlay == .board && once {
                        once = false
                        movingTile = tile
                    }
                }
            }
        case true:
            
            for tile in allTiles {
                if !myBoard.frame.contains(gesture.location(in: view)){
                    
                    if tile.frame.contains(gesture.location(in: view)) && tile == pile && once {
                        guard pileOfTiles > 0 else {return}
                        once = false
                        pileOfTiles -= 1
                        let newTile = Tile()
                        newTile.mySymbol = pickRandomLetter()
                        allTiles.append(newTile)
                        newTile.myWhereInPlay = .atBat
                        newTile.mySize = .large
                        
                        newTile.atBatTileOrder = seatWarmerFunc()
                        
                        view.addSubview(newTile)
                        dropTileWhereItBelongs(tile: newTile)
                        // Set1.atBatRawValue.append(newTile.mySymbol.rawValue)
                        LoadSaveCoreData.sharedInstance.saveState()
                    } else if tile.frame.contains(gesture.location(in: view)) && tile.myWhereInPlay == .onDeck && once {
                        once = false
                        
                        
                        tile.atBatTileOrder = seatWarmerFunc()
                        tile.myWhereInPlay = .atBat
                        tile.mySize = .large
                        
                        tile.topOfBlock.backgroundColor = myColor.purple
                        tile.text.textColor = .black
                        dropTileWhereItBelongs(tile: tile)
                        // Set1.atBatRawValue.append(tile.mySymbol.rawValue)
                        onDeckTiles.removeAll()
                        for tile in allTiles {
                            if tile.myWhereInPlay == .onDeck {
                                onDeckTiles.append(tile)
                            }
                        }
                        rearrangeOnDeck(gone: tile.onDeckTileOrder!)
                    } else {
                        delay(bySeconds: 0.1) { self.once = true }
                    }
                    //maybe fixes the color problem???
                    var tileCount = 0
                    for tile in allTiles {
                        if tile.myWhereInPlay == .onDeck {
                            tile.topOfBlock.backgroundColor = myColor.teal
                            tile.text.textColor = .white
                            tileCount += 1
                            if tileCount == allTiles.count {
                                once = true
                            }
                        }
                    }
                }
            }
            storeWholeState()
            LoadSaveCoreData.sharedInstance.saveState()
        }
        
        if banner.frame.contains(gesture.location(in: view)) {
            bannerFunc()
        }
    }
    private func seatWarmerFunc() -> Int {
        var container = [Int]()
        var seatWarmer = Int()
        
        for tile2 in allTiles {
            if let order = tile2.atBatTileOrder {
                if tile2.myWhereInPlay == .atBat {
                    container.append(order)
                }
            }
        }
        
        if container.count + onTheBoard >= 6 {refillMode = false}
        o: for i in 0...6 {
            
            if !container.contains(i) {
                
                seatWarmer = i
                break o
            }
        }
        return seatWarmer
    }
    
    private func rearrangeOnDeck(gone: Int) {
        for tile in allTiles {
            if tile.myWhereInPlay == .onDeck {
                if tile.onDeckTileOrder! > gone {
                    tile.onDeckTileOrder? -= 1
                    
                }
                dropTileWhereItBelongs(tile: tile)
            }
        }
    }
    
    @objc private func doubleTapFunc(_ gesture: UITapGestureRecognizer) {
        if Set1.isZoomed == false && myBoard.frame.contains(gesture.location(in: view)) {
            myBoard.zoomIn() { () -> Void in
                
                myBoard.contentOffset.x = gesture.location(in: myBoard).x*(myBoard.scale) - myBoard.frame.width/2
                
                if myBoard.contentOffset.x < 0 {
                    myBoard.contentOffset.x = 0
                }
                if myBoard.contentOffset.x > myBoard.frame.width*(myBoard.scale - 1) {
                    myBoard.contentOffset.x = myBoard.frame.width*(myBoard.scale - 1)
                }
                myBoard.contentOffset.y = gesture.location(in: myBoard).y*(myBoard.scale) - myBoard.frame.height/2
                if myBoard.contentOffset.y < 0 {
                    myBoard.contentOffset.y = 0
                }
                if myBoard.contentOffset.y > myBoard.frame.height*(myBoard.scale - 1) {
                    myBoard.contentOffset.y = myBoard.frame.height*(myBoard.scale - 1)
                }
            }
            
        } else if myBoard.frame.contains(gesture.location(in: view)) {
            myBoard.zoomOut(){() -> Void in}
            
        }
        for tile in allTiles {
            dropTileWhereItBelongs(tile: tile)
        }
        refreshSizes()
        for tile in allTiles {
            if tile.myWhereInPlay == .atBat {
                
            }
        }
    }
    
    var iWantToScrollMyBoard = true
    
    @objc private func moveTile2(_ gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            once = true
            for tile in allTiles {
                if tile.frame.contains(gesture.location(in: view)) && (tile.myWhereInPlay == .onDeck || tile == pile) {
                    if tile.frame.contains(gesture.location(in: view)) && tile == pile && once {
                        guard pileOfTiles > 0 else {return}
                        once = false
                        pileOfTiles -= 1
                        let newTile = Tile()
                        newTile.mySymbol = pickRandomLetter()
                        allTiles.append(newTile)
                        newTile.myWhereInPlay = .atBat
                        newTile.mySize = .large
                        
                        newTile.atBatTileOrder = seatWarmerFunc()
                        
                        view.addSubview(newTile)
                        dropTileWhereItBelongs(tile: newTile)
                        // Set1.atBatRawValue.append(newTile.mySymbol.rawValue)
                        LoadSaveCoreData.sharedInstance.saveState()
                    } else if tile.frame.contains(gesture.location(in: view)) && tile.myWhereInPlay == .onDeck && once {
                        once = false
                        
                        
                        tile.atBatTileOrder = seatWarmerFunc()
                        tile.myWhereInPlay = .atBat
                        tile.mySize = .large
                        
                        tile.topOfBlock.backgroundColor = myColor.purple
                        tile.text.textColor = .black
                        dropTileWhereItBelongs(tile: tile)
                        // Set1.atBatRawValue.append(tile.mySymbol.rawValue)
                        onDeckTiles.removeAll()
                        for tile in allTiles {
                            if tile.myWhereInPlay == .onDeck {
                                onDeckTiles.append(tile)
                            }
                        }
                        rearrangeOnDeck(gone: tile.onDeckTileOrder!)
                    } else {
                        delay(bySeconds: 0.1) { self.once = true }
                    }
                    //maybe fixes the color problem???
                    var tileCount = 0
                    for tile in allTiles {
                        if tile.myWhereInPlay == .onDeck {
                            tile.topOfBlock.backgroundColor = myColor.teal
                            tile.text.textColor = .white
                            tileCount += 1
                            if tileCount == allTiles.count {
                                once = true
                            }
                        }
                    }
                }
            }
            
            
        default: break
        }
    }
    
    
    @objc private func moveTile(_ gesture: UIPanGestureRecognizer) {
      
        switch gesture.state {
        case .began:
            
            outer: for tile in allTiles {
                if !myBoard.frame.contains(gesture.location(in: view)) {
                    iWantToScrollMyBoard = false
                    if tile.frame.contains(gesture.location(in: view)) && !tile.isLockedInPlace && tile.myWhereInPlay == .atBat {
                        
                        movingTile = tile
                        movingTile?.layer.zPosition = 10
                        movingTile?.mySize = .large
                        //isNotSameTile = true
                        if movingTile?.slotsIndex != nil {
                            myBoard.slots[(movingTile?.slotsIndex!)!].isOccupied = false
                        }
                    }
                    //break outer
                } else {
                    if tile.frame.contains(gesture.location(in: myBoard)) && !tile.isLockedInPlace && tile.myWhereInPlay == .board {
                        
                        iWantToScrollMyBoard = false
                        movingTile = tile
                        movingTile?.mySize = .large
                        //isNotSameTile = true
                        if movingTile?.slotsIndex != nil {
                            myBoard.slots[(movingTile?.slotsIndex!)!].isOccupied = false
                        }
                       // break outer
                    }
                }
            }
            
        case .changed:
            
            if iWantToScrollMyBoard && Set1.isZoomed {
                
                let translation = gesture.translation(in: view)
                
                if myBoard.contentOffset.x - translation.x > 0 && myBoard.contentOffset.x - translation.x < myBoard.frame.width*(myBoard.scale - 1) {
                    myBoard.contentOffset.x -= translation.x
                }
                
                
                if myBoard.contentOffset.y - translation.y > 0 && myBoard.contentOffset.y - translation.y < myBoard.frame.width*(myBoard.scale - 1) {
                    myBoard.contentOffset.y -= translation.y
                }
                
                gesture.setTranslation(CGPoint(x:0,y:0), in: self.view)
                if myBoard.contentOffset.x < 0 {
                    myBoard.contentOffset.x = 0
                }
                if myBoard.contentOffset.y < 0 {
                    myBoard.contentOffset.y = 0
                }
            }
            
            
            if movingTile != nil {
                
                let translation = gesture.translation(in: view)
                movingTile?.center = CGPoint(x: (movingTile?.center.x)! + translation.x, y: (movingTile?.center.y)! + translation.y)
                
                gesture.setTranslation(CGPoint(x:0,y:0), in: self.view)
                
                //  moving in and out of board frame
                if myBoard.frame.contains(CGPoint(x: movingTile!.frame.origin.x + movingTile!.frame.width/2, y: movingTile!.frame.maxY)) && !movingTile!.isDescendant(of: myBoard) {
                    
                    movingTile!.removeFromSuperview()
                    onTheBoard += 1
                    movingTile!.frame.origin.y -= myBoard.frame.origin.y - myBoard.contentOffset.y
                    movingTile!.frame.origin.x += myBoard.contentOffset.x - myBoard.frame.origin.x
                    myBoard.addSubview(movingTile!)
                    
                } else if !myBoard.bounds.contains(CGPoint(x: movingTile!.frame.origin.x + movingTile!.frame.width/2, y: movingTile!.frame.maxY)) && movingTile!.isDescendant(of: myBoard) {
                   
                    movingTile!.removeFromSuperview()
                    onTheBoard -= 1
                    movingTile!.frame.origin.y += myBoard.frame.origin.y - myBoard.contentOffset.y
                    movingTile!.frame.origin.x -= myBoard.contentOffset.x - myBoard.frame.origin.x
                    movingTile?.atBatTileOrder = nil
                    view.addSubview(movingTile!)
                    movingTile?.myWhereInPlay = .atBat
                    
                    
                }
                
                // enable swapping of atBat tiles
                if !movingTile!.isDescendant(of: myBoard) {
                    for tile in allTiles {
                        if tile.myWhereInPlay == .atBat && tile != movingTile {
                            guard movingTile?.atBatTileOrder != nil else {movingTile?.atBatTileOrder = seatWarmerFunc(); reOrderAtBat(); return}
                            if tile.center.x > (movingTile?.center.x)! && (movingTile?.atBatTileOrder!)! > tile.atBatTileOrder! {
                                
                                movingTile!.atBatTileOrder = tile.atBatTileOrder
                                tile.atBatTileOrder! += 1
                                
                                
                            } else if tile.center.x < (movingTile?.center.x)! && (movingTile?.atBatTileOrder!)! < tile.atBatTileOrder! {
                                
                                movingTile!.atBatTileOrder = tile.atBatTileOrder
                                tile.atBatTileOrder! -= 1
                            }
                            let order = tile.atBatTileOrder!
                            let x = 13*self.sw/375 + CGFloat(order)*50*self.sw/375
                            let y = 13*self.sh/667 + myBoard.frame.maxY
                            UIView.animate(withDuration: 0.3) {
                                tile.frame.origin = CGPoint(x: x, y: y)
                            }
                        }
                    }
                }
                
                reOrderAtBat()
            }
        case .ended:

           iWantToScrollMyBoard = true
            if trash.frame.contains(gesture.location(in: view)) && movingTile != nil {
                if playButton.isDescendant(of: view) {
                    
                }
                UIView.animate(withDuration: 0.1) {
                    self.movingTile?.frame.origin = CGPoint(x: 345*self.sw/375, y: 620*self.sh/667)
                    self.movingTile?.topOfBlock.frame.size = CGSize(width: 0, height: 0)
                    self.movingTile?.shadowOfBlock.frame.size = CGSize(width: 0, height: 0)
                    self.movingTile?.text.frame.size = CGSize(width: 0, height: 0)
                }
                delay(bySeconds: 0.3) {
                    self.movingTile?.removeFromSuperview()
                    self.movingTile?.myWhereInPlay = .trash
                    self.movingTile?.atBatTileOrder = nil
                    self.refillMode = true
                    self.movingTile = nil
                    self.movingTile?.layer.zPosition = 0
                    self.rearrangeAtBat()
                }
            } else if movingTile != nil {
                var ct = 0
                outer: for slotView in myBoard.slots {
                    var largerFrame = CGRect()
                    if !Set1.isZoomed {
                        largerFrame = CGRect(x: slotView.frame.origin.x - 1, y: slotView.frame.origin.y - 1, width: slotView.frame.width + 1, height: slotView.frame.height + 1)
                    } else {
                        largerFrame = CGRect(x: slotView.frame.origin.x - 2.5, y: slotView.frame.origin.y - 2.5, width: slotView.frame.width + 2.5, height: slotView.frame.height + 2.5)
                    }
                    if largerFrame.contains(gesture.location(in: myBoard)) && !slotView.isOccupied && myBoard.frame.contains(gesture.location(in: view)) {
                        guard slotView.isOccupied == false else {movingTile?.myWhereInPlay = .atBat; movingTile?.atBatTileOrder = seatWarmerFunc(); onTheBoard -= 1;movingTile?.removeFromSuperview(); view.addSubview(movingTile!); dropTileWhereItBelongs(tile: movingTile!); return}
                        slotView.isOccupied = true
                        movingTile?.slotsIndex = ct
                        movingTile?.myWhereInPlay = .board
                        movingTile?.atBatTileOrder = nil
                        //  moveButton()
                        movingTile?.row = slotView.row
                        movingTile?.column = slotView.column
                        if Set1.isZoomed == false {
                            myBoard.zoomIn() { () -> Void in
                                
                                // moveButton()
                                myBoard.contentOffset.x = slotView.frame.origin.x - myBoard.bounds.width/2 + slotView.frame.width/2
                                if myBoard.contentOffset.x < 0 {
                                    myBoard.contentOffset.x = 0
                                }
                                myBoard.contentOffset.y = slotView.frame.origin.y - myBoard.bounds.height/2 + slotView.frame.width/2
                                if myBoard.contentOffset.y < 0 {
                                    myBoard.contentOffset.y = 0
                                }
                                if myBoard.contentOffset.x > myBoard.frame.width*(myBoard.scale - 1) {
                                    myBoard.contentOffset.x = myBoard.frame.width*(myBoard.scale - 1)
                                }
                                if myBoard.contentOffset.y > myBoard.frame.height*(myBoard.scale - 1) {
                                    myBoard.contentOffset.y = myBoard.frame.height*(myBoard.scale - 1)
                                }
                                
                            }
                        }
                        if (movingTile?.isDescendant(of: myBoard))! {
                            
                            movingTile?.atBatTileOrder = seatWarmerFunc()
                            
                        }
                        
                        for tile in allTiles {
                            dropTileWhereItBelongs(tile: tile)
                        }
                        refreshSizes()
                        movingTile?.layer.zPosition = 0
                        movingTile = nil
                        break outer
                    }
                    ct += 1
                    if ct == 225 {
                        //make it belong back in atBat
                        movingTile?.removeFromSuperview(); view.addSubview(movingTile!); dropTileWhereItBelongs(tile: movingTile!)}
                }
                movingTile?.layer.zPosition = 0
                movingTile = nil
                rearrangeAtBat()
            }
        default:
            break
        }
        
        
    }
    //    private func moveButton() {
    //        guard myBoard.slots.count > 0 else {return}
    //        if myBoard.slots[14].isOccupied || myBoard.slots[29].isOccupied || myBoard.slots[13].isOccupied || myBoard.slots[28].isOccupied {
    //
    //            // self.playButton.frame.origin = CGPoint(x: 312*self.sw/375, y: 425*self.sh/667)
    //
    //
    //
    //
    //
    //        }
    //
    func dropTileWhereItBelongs(tile: Tile) {
        switch tile.myWhereInPlay {
        case .board:
            tile.removeFromSuperview()
            myBoard.addSubview(tile)
            let row = tile.row!
            let column = tile.column!
            var x = 0.5*sw/375 + CGFloat(column)*23*sw/375
            var y = 0.5*sw/375 + CGFloat(row)*23*sw/375
            if Set1.isZoomed {
                let scale = myBoard.scale
                x = scale*(0.5*sw/375 + CGFloat(column)*23*sw/375)
                y = scale*(0.5*sw/375 + CGFloat(row)*23*sw/375)
            }
            tile.frame.origin = CGPoint(x: x, y: y)
            tile.shadowOfBlock.alpha = 0.0
            tile.topOfBlock.layer.borderColor = UIColor.clear.cgColor
        // tile.topOfBlock.layer.borderWidth = 0
        case .atBat:
            let order = tile.atBatTileOrder!
            let x = 13*self.sw/375 + CGFloat(order)*50*self.sw/375
            let y = 29*self.sh/667 + myBoard.frame.maxY
            UIView.animate(withDuration: 0.3) {
                tile.frame.origin = CGPoint(x: x, y: y)
            }
            tile.shadowOfBlock.alpha = 0.0
            tile.topOfBlock.layer.borderColor = UIColor.black.cgColor
        case .pile:
            tile.shadowOfBlock.alpha = 1.0
            tile.topOfBlock.layer.borderColor = UIColor.black.cgColor
        case .trash: break
        case .onDeck:
            let amount = onDeckTiles.count
            let order = tile.onDeckTileOrder!
            var x: CGFloat = 0
            var y: CGFloat = 0
            switch amount {
            case 1:
                y = 616
                x = 170.5
            case 2:
                y = 616
                switch order {
                case 0:
                    x = 150
                case 1:
                    x = 191
                default:
                    break
                }
                
            case 3:
                y = 616
                switch order {
                case 0:
                    x = 129.5
                case 1:
                    x = 170.5
                case 2:
                    x = 211.5
                default:
                    break
                }
            case 4:
                y = 616
                switch order {
                case 0:
                    x = 109
                case 1:
                    x = 150
                case 2:
                    x = 191
                case 3:
                    x = 232
                default:
                    break
                }
            case 5:
                y = 616
                switch order {
                case 0:
                    x = 88.5
                case 1:
                    x = 129.5
                case 2:
                    x = 170.5
                case 3:
                    x = 211.5
                case 4:
                    x = 252.5
                default:
                    break
                }
            case 6...14:
                y = 616
                switch order {
                case 0:
                    x = 88.5
                case 1:
                    x = 129.5
                case 2:
                    x = 170.5
                case 3:
                    x = 211.5
                case 4:
                    x = 252.5
                default:
                    break
                }
                
            default:
                break
            }
            switch amount {
            case 6:
                switch order {
                case 5:
                    y = 575
                    x = 170.5
                    
                default:
                    break
                }
            case 7:
                switch order {
                case 5:
                    y = 575
                    x = 150
                case 6:
                    y = 575
                    x = 191
                default:
                    break
                }
            case 8:
                switch order {
                case 5:
                    y = 575
                    x = 129.5
                case 6:
                    y = 575
                    x = 170.5
                case 7:
                    y = 575
                    x = 211.5
                default:
                    break
                }
            case 9:
                switch order {
                case 5:
                    y = 575
                    x = 109
                case 6:
                    y = 575
                    x = 150
                case 7:
                    y = 575
                    x = 191
                case 8:
                    y = 575
                    x = 232
                default:
                    break
                }
            case 10...14:
                switch order {
                case 5:
                    y = 575
                    x = 88.5
                case 6:
                    y = 575
                    x = 129.5
                case 7:
                    y = 575
                    x = 170.5
                case 8:
                    y = 575
                    x = 211.5
                case 9:
                    y = 575
                    x = 252.5
                default:
                    break
                }
            default:
                break
            }
            switch amount {
            case 11:
                switch order {
                case 10:
                    y = 534
                    x = 170.5
                    
                default:
                    break
                }
            case 12:
                switch order {
                case 10:
                    y = 534
                    x = 150
                case 11:
                    y = 534
                    x = 191
                default:
                    break
                }
            case 13:
                switch order {
                case 10:
                    y = 534
                    x = 129.5
                case 11:
                    y = 534
                    x = 170.5
                case 12:
                    y = 534
                    x = 211.5
                default:
                    break
                }
            case 14:
                switch order {
                case 10:
                    y = 534
                    x = 109
                case 11:
                    y = 534
                    x = 150
                case 12:
                    y = 534
                    x = 191
                case 13:
                    y = 534
                    x = 232
                default:
                    break
                }
            case 15:
                switch order {
                case 10:
                    y = 534
                    x = 88.5
                case 11:
                    y = 534
                    x = 129.5
                case 12:
                    y = 534
                    x = 170.5
                case 13:
                    y = 534
                    x = 211.5
                case 14:
                    y = 534
                    x = 252.5
                default:
                    break
                }
                tile.shadowOfBlock.alpha = 1.0
                tile.topOfBlock.layer.borderColor = UIColor.black.cgColor
            default:
                break
            }
            
            
            tile.frame.origin = CGPoint(x: x*self.sw/375, y: y*self.sh/667)
            
        }
    }
    
    private func pickRandomLetter() -> Tile.symbol {
        let random = arc4random_uniform(98)
        let myTile = Tile()
        switch random {
        case 0...11:
            myTile.mySymbol = .e
        case 12...20:
            myTile.mySymbol = .a
        case 21...29:
            myTile.mySymbol = .i
        case 30...37:
            myTile.mySymbol = .o
        case 38...43:
            myTile.mySymbol = .n
        case 44...49:
            myTile.mySymbol = .r
        case 50...55:
            myTile.mySymbol = .t
        case  56...59:
            myTile.mySymbol = .l
        case 60...63:
            myTile.mySymbol = .s
        case 64...67:
            myTile.mySymbol = .u
        case 68...71:
            myTile.mySymbol = .d
        case 72...74:
            myTile.mySymbol = .g
        case 75,76: myTile.mySymbol = .b; case 77,78: myTile.mySymbol = .c; case 79,80: myTile.mySymbol = .f; case 81,82: myTile.mySymbol = .h; case 83: myTile.mySymbol = .j; case 84: myTile.mySymbol = .k; case 85,86: myTile.mySymbol = .m; case 87,88: myTile.mySymbol = .p; case 89: myTile.mySymbol = .q; case 90,91: myTile.mySymbol = .v; case 92,93: myTile.mySymbol = .w; case 94: myTile.mySymbol = .x; case 95,96: myTile.mySymbol = .y; case 97: myTile.mySymbol = .z
        default:
            break
        }
        return myTile.mySymbol
    }
    
    
    func refreshSizes() {
        for tile in allTiles {
            switch tile.myWhereInPlay {
            case .trash: break
            case .atBat:
                tile.mySize = .large
                tile.topOfBlock.layer.borderColor = UIColor.black.cgColor
            case .pile:
                tile.topOfBlock.layer.borderColor = UIColor.black.cgColor
            case .onDeck:
                tile.mySize = .medium
                tile.topOfBlock.layer.borderColor = UIColor.black.cgColor
            case .board:
                tile.mySize = .small
                tile.topOfBlock.layer.borderColor = UIColor.clear.cgColor
                if Set1.isZoomed {
                    tile.mySize = .large
                    tile.topOfBlock.layer.borderColor = UIColor.clear.cgColor
                }
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UIPanGestureRecognizer || gestureRecognizer is UITapGestureRecognizer) && !refillMode {
            return true
        } else {
            return false
        }
    }
    
    private func restart() {
        startingNewGame = true
        view.subviews.forEach({ $0.removeFromSuperview() })
        for case let view as Tile in myBoard.subviews {
            view.removeFromSuperview()
        }
        
        isFirstPlayFunc = true
        
        allTiles.removeAll()
        
        onDeckTiles.removeAll()
        wordTiles.removeAll()
        wordTilesPerpendicular.removeAll()
        for slot in myBoard.slots {
            slot.isOccupied = false
            slot.isPermanentlyOccupied = false
            slot.isOccupiedFromStart = false
        }
        pileOfTiles = 25
        myBoard.zoomOut(){}
        myLoad()
        for tile in allTiles {
            if tile.isStarterBlock {
                tile.topOfBlock.backgroundColor = myColor.purple
                tile.text.textColor = .black
            }
        }
        pile.topOfBlock.backgroundColor = myColor.teal
        pile.text.textColor = .black
        startingNewGame = false
        storeWholeState()
        LoadSaveCoreData.sharedInstance.saveState()
    }
    
    func storeWholeState() {
        Set1.winState = isWin
        var atBatRawValue = [String]()
        var onDeckRawValue = [String]()
        var buildableRawValue = [String]()
        var startRawValue = [String]()
        var indexBuildable = [Int]()
        var indexStart = [Int]()
        Set1.pileAmount = pileOfTiles
        
        for tile in allTiles {
            
            if tile.isBuildable {
                indexBuildable.append(tile.slotsIndex!)
                
                buildableRawValue.append(tile.mySymbol.rawValue)
            }
            if tile.isStarterBlock {
                indexStart.append(tile.slotsIndex!)
                startRawValue.append(tile.mySymbol.rawValue)
            }
            if tile.myWhereInPlay == .atBat {
                atBatRawValue.append(tile.mySymbol.rawValue)
            }
            if tile.myWhereInPlay == .onDeck {
                onDeckRawValue.append(tile.mySymbol.rawValue)
            }
        }
        
        Set1.atBatRawValue = atBatRawValue
        Set1.onDeckRawValue = onDeckRawValue
        Set1.buildableRawValue = buildableRawValue
        Set1.indexBuildable = indexBuildable
        Set1.startRawValue = startRawValue
        Set1.indexStart = indexStart
        
    }
    
    private func whatsMySymbol(character: String) -> Tile.symbol {
        switch character {
        case "A": return .a; case "B": return .b; case "C": return .c; case "D": return .d; case "E": return .e; case "F": return .f; case "G": return .g; case "H": return .h; case "I": return .i; case "J": return .j; case "K": return .k; case "L": return .l; case "M": return .m; case "N": return .n; case "O": return .o; case "P": return .p; case "Q": return .q; case "R": return .r; case "S": return .s; case "T": return .t; case "U": return .u; case "V": return .v; case "W": return .w; case "X": return .x; case "Y": return .y; case "Z": return .z;
            
        default:
            return .a
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let yourVC = segue.destination as? MenuViewController {
            yourVC.modalPresentationStyle = .overCurrentContext
        }
    }
    
    func purchase(productId: String) {
        view.addSubview(progressHUD)
        SwiftyStoreKit.purchaseProduct(productId) { result in
            switch result {
            case .success( _):
                
                if productId == "com.wordsWithNoFriends.boosts" {
                    
                    self.amountOfBoosts += 3
                    
                }
                
                self.progressHUD.removeFromSuperview()
            case .error(let error):
                print("error: \(error)")
                print("Purchase Failed: \(error)")
                
                self.progressHUD.removeFromSuperview()
                
                let alert = UIAlertController(title: "Purchase", message: "Purchase Failed", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    
    
    
}




