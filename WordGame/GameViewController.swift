//
//  ViewController.swift
//  WordGame
//
//  Created by Aaron Halvorsen on 4/21/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    let myColor = CustomColor()
    let myBoard = Board.sharedInstance
    var pan = UIPanGestureRecognizer()
    var tap = UITapGestureRecognizer()
    var doubleTap = UITapGestureRecognizer()
    var allTiles = [Tile]()
    var movingTile: Tile?
    var onDeckTiles = [Tile]()
    // var tilesBeingPlayed = [Tile]()
    let pile = Tile()
    var pileOfTiles = 15 { didSet { pileOfTilesString = String(pileOfTiles); pile.text.text = "x" + pileOfTilesString } }
    var pileOfTilesString = "x15"
    var isNotSameTile = false
    var playButton = UIButton()
    var refillMode = false {didSet{
        if refillMode {
            view.removeGestureRecognizer(pan)
            for tile in allTiles {
                if tile.myWhereInPlay == .onDeck || tile.myWhereInPlay == .pile {
                    tile.topOfBlock.backgroundColor = self.myColor.black80
                    tile.text.textColor = .white
                }
            }
            
            
        } else {
            view.addGestureRecognizer(pan)
            for tile in allTiles {
                if tile.myWhereInPlay == .onDeck || tile.myWhereInPlay == .pile {
                    tile.topOfBlock.backgroundColor = .white
                    tile.text.textColor = .black
                }
            }
        }}}
    
    
    override func viewWillAppear(_ animated: Bool) {
        doubleTap.numberOfTapsRequired = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = myColor.white245
        view.addSubview(myBoard)
        pan = UIPanGestureRecognizer(target: self, action: #selector(GameViewController.moveTile(_:)))
        view.addGestureRecognizer(pan)
        tap = UITapGestureRecognizer(target: self, action: #selector(GameViewController.tapTile(_:)))
        view.addGestureRecognizer(tap)
        pile.text.font = UIFont(name: "HelveticaNeue-Bold", size: 14*fontSizeMultiplier)
        pile.frame = CGRect(x: 15*sw/375, y: 616*sh/667, width: 34*sw/375, height: 34*sw/375)
        pile.myWhereInPlay = .pile
        view.addSubview(pile)
        pile.text.text = pileOfTilesString
        allTiles.append(pile)
        addTilesToBoard()
        startGameWithTilesOnBoard(difficulty: .medium)
        playButton.frame = CGRect(x: 87.5*sw/375, y: 615*sh/667, width: 200*sw/375, height: 40*sw/375)
        playButton.backgroundColor = myColor.white245
        playButton.setTitle("\u{25B6}", for: .normal)
        playButton.addTarget(self, action: #selector(GameViewController.playFunc(_:)), for: .touchUpInside)
        playButton.layer.borderWidth = 2*sw/375
        playButton.layer.cornerRadius = 3
        playButton.layer.masksToBounds = true
        playButton.layer.borderColor = UIColor.black.cgColor
        playButton.setTitleColor(.black, for: .normal)
        
        myBoard.delegate = self
        self.myBoard.showsHorizontalScrollIndicator = false
        self.myBoard.showsVerticalScrollIndicator = false
        doubleTap.numberOfTapsRequired = 2
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(GameViewController.doubleTapFunc(_:)))
        view.addGestureRecognizer(doubleTap)
        tap.require(toFail: doubleTap)
        doubleTap.numberOfTapsRequired = 2
    }
    
    var wordTiles = [Tile]()
    private func findTheString(callback: (_ word: String?, _ rowWord: Bool, _ tilesInPlay: [Tile]) -> Void) {
        var tilesInPlay = [Tile]()
        for tile in allTiles {
            if tile.myWhereInPlay == .board && tile.isLockedInPlace == false {
                tilesInPlay.append(tile)
            }
        }
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
                    print("blah")
                    if isSameRow {
                        print("blah1")
                        if tile.row == smallestRow && tile.column == smallestColumn - 1 {
                            print("blah3")
                            smallestColumn -= 1
                            tilesInPlay.append(tile)
                        }
                    } else if isSameColumn {
                        print("blah2")
                        if tile.row == smallestRow - 1 && tile.column == smallestColumn {
                            print("blah4")
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
                            print(word)
                            print("wordtile")
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
                            print("wordtile")
                            wordTiles.append(tile)
                            print(word)
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
    var isFirstPlayFunc = true
    @objc private func playFunc(_ button: UIButton) {
        
        guard isFirstPlayFunc == true else {return}
        isFirstPlayFunc = false
        
        findTheString() { (word,isRowWord,tilesInPlay) -> Void in
            if let w = word {
                print(w)
                let everythingChecksOutPerpendicular = perpendicularWords(isRowWord: isRowWord, tilesInPlay: tilesInPlay)
                myBoard.zoomOut() { () -> Void in
                    for tile in allTiles {
                        dropTileWhereItBelongs(tile: tile)
                    }
                    
                    refreshSizes()
                }
                
                guard isReal(word: w.lowercased()) != nil else {return}
                if isReal(word: w.lowercased())! && everythingChecksOutPerpendicular {
                    
                    for i in 0..<wordTiles.count {
                        wordTiles[i].isBuildable = true
                        delay(bySeconds: 0.2*Double(i)+0.4) {
                            if self.playButton.isDescendant(of: self.view) {
                                self.playButton.removeFromSuperview()
                            }
                            self.wordTiles[i].isLockedInPlace = true
                            if self.wordTiles[i].isStarterBlock {
                                self.wordTiles[i].isStarterBlock = false
                                self.wordTiles[i].topOfBlock.backgroundColor = self.myColor.black80
                                self.wordTiles[i].text.textColor = .white
                            }
                            if i == self.wordTiles.count - 1 {
                                self.wordTiles.removeAll()
                                //  self.tilesBeingPlayed.removeAll()
                                self.isFirstPlayFunc = true
                                self.startBonuses()
                                self.lockTilesAndRefillRack()
                            }
                            
                        }
                        
                    }
                    delay(bySeconds: 3) {
                        
                    }
                    
                } else {
                    wordTiles.removeAll()
                   wordAlert(word: w)
                }
                
            } else {
                wordTiles.removeAll()
                let alert = UIAlertController(title: "Retry", message: "Can only spell one word at a time", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    private func wordAlert(word: String) {
        let alert = UIAlertController(title: word.uppercased(), message: "Not a word", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func perpendicularWords(isRowWord: Bool, tilesInPlay: [Tile]) -> Bool {
        var everythingChecksOut = true
        var indexesOfWords = [Int]()
        var smallestRow = 16
        var smallestColumn = 16
        var word = String()
        
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
                loop: for tile in allTiles {
                    var isKeepGoing = true
                    while isKeepGoing {
                        isKeepGoing = false
                        if tile.myWhereInPlay == .board && myBoard.slots[index].column == tile.column! && tile.row! + 1 == smallestRow {
                            
                            smallestRow = tile.row!
                            isKeepGoing = true
                            break loop
                        }
                    }
                    
                }
                
                var dontQuit = true
                while dontQuit {
                    var count = 1
                    outerLoop:  for tile in allTiles {
                        
                        if tile.column != nil && tile.myWhereInPlay == .board {
                            
                            
                            if tile.row! == smallestColumn && tile.row! == smallestRow {
                                
                                
                                word += tile.mySymbol.rawValue
                                
                                smallestRow += 1
                                break outerLoop
                            } else if allTiles.count == count {
                                
                                
                                dontQuit = false
                                if !isReal(word: word.lowercased()){
                                    everythingChecksOut = false
                                    wordAlert(word: word)
                                }
                            }
                            
                        } else if allTiles.count == count {
                            dontQuit = false
                            if !isReal(word: word.lowercased()) {
                                everythingChecksOut = false
                                wordAlert(word: word)
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
                loop: for tile in allTiles {
                    var isKeepGoing = true
                    while isKeepGoing {
                        isKeepGoing = false
                        if tile.myWhereInPlay == .board && myBoard.slots[index].row == tile.row! && tile.column! + 1 == smallestColumn {
                            
                            smallestColumn = tile.column!
                            isKeepGoing = true
                            break loop
                        }
                    }
                    
                }
                
                var dontQuit = true
                while dontQuit {
                    var count = 1
                    outerLoop:  for tile in allTiles {
                        
                        if tile.row != nil && tile.myWhereInPlay == .board {
                            
                            
                            if tile.row! == smallestRow && tile.column! == smallestColumn {
                                
                                
                                word += tile.mySymbol.rawValue
                               
                                smallestColumn += 1
                                break outerLoop
                            } else if allTiles.count == count {
                                
                                
                                dontQuit = false
                              if !isReal(word: word.lowercased()) {
                                everythingChecksOut = false
                                wordAlert(word: word)
                                }
                            }
                            
                        } else if allTiles.count == count {
                            dontQuit = false
                            if !isReal(word: word.lowercased()) {
                                everythingChecksOut = false
                                wordAlert(word: word)
                            }

                        }
                        count += 1
                    }
                }
                
                
            }
        }
        
        
        
        
        return everythingChecksOut
    }
    
    private func startBonuses() {
        
    }
    
    private func lockTilesAndRefillRack() {
        
        refillMode = true
    }
    
    
    func isReal(word: String) -> Bool? {
        var isWordBuildable = false
        print(isWordBuildable)
        print(wordTiles)
        for tile in wordTiles {
            print(isWordBuildable)
            if tile.isBuildable { isWordBuildable = true }
            print(isWordBuildable)
        }
        guard isWordBuildable == true else {
            var isFirstPlayFunc = true
            let alert = UIAlertController(title: word.uppercased(), message: "Must build off black tiles", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return nil
        }
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.characters.count)
        let wordRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return wordRange.location == NSNotFound
    }
    
    func addTilesToBoard() {
        for i in 0...4 {
            let tile = Tile()
            tile.mySymbol = pickRandomLetter()
            tile.onDeckTileOrder = i
            tile.myWhereInPlay = .onDeck
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
            var oneIndexRow = 20
            var oneIndex = -1
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
            break
        }
        
    }
    var tapTileOnlyOnce = true
    @objc private func tapTile(_ gesture: UITapGestureRecognizer) {
        
        switch refillMode {
        case false:
            for tile in allTiles {
                if !myBoard.frame.contains(gesture.location(in: view)){
                    if tile.frame.contains(gesture.location(in: view)) && !tile.isLockedInPlace && tile.myWhereInPlay == .atBat {
                        movingTile = tile
                    }
                } else {
                    if tile.frame.contains(gesture.location(in: myBoard)) && !tile.isLockedInPlace && tile.myWhereInPlay == .board {
                        
                        movingTile = tile
                    }
                }
            }
        case true:
            
            for tile in allTiles {
                if !myBoard.frame.contains(gesture.location(in: view)){
                    
                    if tile.frame.contains(gesture.location(in: view)) && tile == pile {
                        
                        pileOfTiles -= 1
                        let newTile = Tile()
                        newTile.mySymbol = pickRandomLetter()
                        allTiles.append(newTile)
                        newTile.myWhereInPlay = .atBat
                        newTile.mySize = .large
                        var container = [Int]()
                        for tile2 in allTiles {
                            if let order = tile2.atBatTileOrder {
                                if tile2.myWhereInPlay == .atBat {
                                    container.append(order)
                                    print(container)
                                }
                            }
                            
                        }
                        if container.count == 6 {refillMode = false}
                        o: for i in 0...6 {
                            
                            if !container.contains(i) {
                                
                                newTile.atBatTileOrder = i
                                break o
                            }
                        }
                        view.addSubview(newTile)
                        dropTileWhereItBelongs(tile: newTile)
                        
                    } else if tile.frame.contains(gesture.location(in: view)) && tile.myWhereInPlay == .onDeck {
                        var container = [Int]()
                        var seatWarmer = Int()
                        
                        for tile2 in allTiles {
                            if let order = tile2.atBatTileOrder {
                                if tile2.myWhereInPlay == .atBat {
                                    container.append(order)
                                    print(container)
                                }
                            }
                            
                        }
                        if container.count == 6 {refillMode = false}
                        o: for i in 0...6 {
                            
                            if !container.contains(i) {
                                
                                seatWarmer = i
                                break o
                            }
                        }
                        tile.myWhereInPlay = .atBat
                        tile.mySize = .large
                        tile.atBatTileOrder = seatWarmer
                        tile.topOfBlock.backgroundColor = .white
                        tile.text.textColor = .black
                        dropTileWhereItBelongs(tile: tile)
                        onDeckTiles.removeAll()
                        for tile in allTiles {
                            if tile.myWhereInPlay == .onDeck {
                                onDeckTiles.append(tile)
                            }
                        }
                        rearrangeOnDeck(gone: tile.onDeckTileOrder!)
                    }
                }
            }
        }
        
    }
    
    private func rearrangeOnDeck(gone: Int) {
        for tile in allTiles {
            if tile.myWhereInPlay == .onDeck {
                print("on deck order")
                print(tile.onDeckTileOrder)
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
    }
    
    var iWantToScrollMyBoard = true
    @objc private func moveTile(_ gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            
            for tile in allTiles {
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
                } else {
                    if tile.frame.contains(gesture.location(in: myBoard)) && !tile.isLockedInPlace && tile.myWhereInPlay == .board {
                        
                        iWantToScrollMyBoard = false
                        movingTile = tile
                        movingTile?.mySize = .large
                        //isNotSameTile = true
                        if movingTile?.slotsIndex != nil {
                            myBoard.slots[(movingTile?.slotsIndex!)!].isOccupied = false
                        }
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
                    print("Entered")
                    movingTile!.removeFromSuperview()
                    movingTile!.frame.origin.y -= myBoard.frame.origin.y - myBoard.contentOffset.y
                    movingTile!.frame.origin.x += myBoard.contentOffset.x - myBoard.frame.origin.x
                    myBoard.addSubview(movingTile!)
                    
                } else if !myBoard.bounds.contains(CGPoint(x: movingTile!.frame.origin.x + movingTile!.frame.width/2, y: movingTile!.frame.maxY)) && movingTile!.isDescendant(of: myBoard) {
                    print("Exited")
                    movingTile!.removeFromSuperview()
                    movingTile!.frame.origin.y += myBoard.frame.origin.y - myBoard.contentOffset.y
                    movingTile!.frame.origin.x -= myBoard.contentOffset.x - myBoard.frame.origin.x
                    view.addSubview(movingTile!)
                    movingTile?.myWhereInPlay = .atBat
                    var container = [Int]()
                    for tile in allTiles {
                        if let order = tile.atBatTileOrder {
                            container.append(order)
                        }
                        
                    }
                    o: for i in 0...6 {
                        if !container.contains(i) {
                            movingTile?.atBatTileOrder = i
                            break o
                        }
                    }
                }
                
                // enable swapping of atBat tiles
                if !movingTile!.isDescendant(of: myBoard) {
                    for tile in allTiles {
                        if tile.myWhereInPlay == .atBat && tile != movingTile {
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
                
                
            }
        case .ended:
            iWantToScrollMyBoard = true
            if movingTile != nil {
                var ct = 0
                outer: for slotView in myBoard.slots {
                    var largerFrame = CGRect()
                    if !Set1.isZoomed {
                        largerFrame = CGRect(x: slotView.frame.origin.x - 1, y: slotView.frame.origin.y - 1, width: slotView.frame.width + 1, height: slotView.frame.height + 1)
                    } else {
                        largerFrame = CGRect(x: slotView.frame.origin.x - 2.5, y: slotView.frame.origin.y - 2.5, width: slotView.frame.width + 2.5, height: slotView.frame.height + 2.5)
                    }
                    if largerFrame.contains(gesture.location(in: myBoard)) && !slotView.isOccupied && myBoard.frame.contains(gesture.location(in: view)) {
                        guard slotView.isOccupied == false else {movingTile?.removeFromSuperview(); view.addSubview(movingTile!); dropTileWhereItBelongs(tile: movingTile!); tapTileOnlyOnce = true; return}
                        slotView.isOccupied = true
                        movingTile?.slotsIndex = ct
                        // movingTile?.mySize = .small
                        movingTile?.myWhereInPlay = .board
                        movingTile?.row = slotView.row
                        movingTile?.column = slotView.column
                        //   tilesBeingPlayed.append(movingTile!)
                        //  zoomInToBoard(point: slotView.center)
                        if Set1.isZoomed == false {
                            myBoard.zoomIn() { () -> Void in
                                if !playButton.isDescendant(of: view) {
                                    view.addSubview(playButton)
                                }
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
            }
        default:
            break
        }
        
        
    }
    
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
            
        case .atBat:
            let order = tile.atBatTileOrder!
            let x = 13*self.sw/375 + CGFloat(order)*50*self.sw/375
            let y = 13*self.sh/667 + myBoard.frame.maxY
            UIView.animate(withDuration: 0.3) {
                tile.frame.origin = CGPoint(x: x, y: y)
            }
        case .pile: break
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
            default:
                break
            }
            
            
            tile.frame.origin = CGPoint(x: x*self.sw/375, y: y*self.sh/667)
            
        }
    }
    
    private func pickRandomLetter() -> Tile.symbol {
        let random = arc4random_uniform(97)
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
            case .atBat:
                tile.mySize = .large
            case .pile: break
            case .onDeck:
                tile.mySize = .medium
            case .board:
                tile.mySize = .small
                if Set1.isZoomed {
                    tile.mySize = .large
                }
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer || gestureRecognizer is UITapGestureRecognizer {
            return true
        } else {
            return false
        }
    }
    
    public func delay(bySeconds seconds: Double, dispatchLevel: DispatchLevel = .main, closure: @escaping () -> Void) {
        let dispatchTime = DispatchTime.now() + seconds
        dispatchLevel.dispatchQueue.asyncAfter(deadline: dispatchTime, execute: closure)
    }
    
    public enum DispatchLevel {
        case main, userInteractive, userInitiated, utility, background
        var dispatchQueue: DispatchQueue {
            switch self {
            case .main:                 return DispatchQueue.main
            case .userInteractive:      return DispatchQueue.global(qos: .userInteractive)
            case .userInitiated:        return DispatchQueue.global(qos: .userInitiated)
            case .utility:              return DispatchQueue.global(qos: .utility)
            case .background:           return DispatchQueue.global(qos: .background)
            }
        }
    }
    
}

