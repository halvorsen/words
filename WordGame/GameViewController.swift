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
    var allTiles = [Tile]()
    var movingTile: Tile?
    var onDeckTiles = [Tile]()
    let ghostTile = Tile()
    let pile = Tile()
    var pileOfTiles = 15 { didSet { pileOfTilesString = String(pileOfTiles); pile.text.text = "x" + pileOfTilesString } }
    var pileOfTilesString = "x15"
    var isNotSameTile = false
    var playButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = myColor.white245
        view.addSubview(myBoard)
        ghostTile.removeFromSuperview()
        pan = UIPanGestureRecognizer(target: self, action: #selector(GameViewController.moveTile(_:)))
        view.addGestureRecognizer(pan)
        tap = UITapGestureRecognizer(target: self, action: #selector(GameViewController.tapTile(_:)))
        view.addGestureRecognizer(tap)
        pile.text.font = UIFont(name: "HelveticaNeue-Bold", size: 14*fontSizeMultiplier)
        pile.frame = CGRect(x: 15*sw/375, y: 616*sh/667, width: 34*sw/375, height: 34*sw/375)
        view.addSubview(pile)
        pile.text.text = pileOfTilesString
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
        view.addSubview(playButton)
        myBoard.delegate = self
    }
    
    private func findTheString() -> String? {
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
        if !isSameColumn && !isSameRow {
            return nil
        }
        if isSameRow {
            print("same row")
            (bool1,bool2,bool3) = checkIfThereIsPriorTileInSameRow(row: smallestRow, column: smallestColumn)
            print("bools: \(bool1) \(bool2) \(bool3)")
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
                
                print("alltilescount: \(allTiles.count)")
                outerLoop:  for tile in allTiles {
                    print("tilerow: \(tile.row)")
                    print("tilecol: \(tile.column)")
                    print("smallestcolumn: \(smallestColumn)")
                    print("smallestrow: \(smallestRow)")
                    if tile.row != nil {
                        print("same row2")
                        
                        if tile.row! == smallestRow && tile.column! == smallestColumn {
                            print("same row3")
                            
                            word += tile.mySymbol.rawValue
                            print(word)
                            smallestColumn += 1
                            break outerLoop
                        } else if allTiles.count == count {
                            print("same row4")
                            
                            dontQuit = false
                            return word
                        }
                        
                    } else if allTiles.count == count {
                        dontQuit = false
                        return word
                    }
                    count += 1
                }
            }
        } else if isSameColumn {
            print("same column")
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
                print("in while loop 1")
                var count = 1
                outerLoop: for tile in allTiles {
                    if tile.row != nil {
                        if tile.row! == smallestRow && tile.column! == smallestColumn {
                            word += tile.mySymbol.rawValue
                            print(word)
                            smallestRow += 1
                            break outerLoop
                        } else if allTiles.count == count {
                            dontQuit = false
                            return word
                        }
                        
                    } else if allTiles.count == count {
                        dontQuit = false
                        return word
                    }
                    count += 1
                }
            }
        }
        return word
    }
    
    private func checkIfThereIsPriorTileInSameRow(row: Int, column: Int) -> (Bool,Bool,Bool) {
        var one = false
        var two = false
        var three = false
        for tile in allTiles {
            if tile.column != nil {
                print("Tile Column: \(tile.column)")
                print("column: \(column)")
                print("tile.row: \(tile.row!)")
                print("row: \(row)")
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
    
    @objc private func playFunc(_ button: UIButton) {
        if let word = findTheString() {
            print(word)
            //check spelling
        } else {
            print("nil outputted")
        }
        
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
        print("rowLow: \(rowLow)")
        print("rowHigh: \(rowHigh)")
        while oneIndexRow < rowLow || oneIndexRow > rowHigh || oneIndex == randomStartSlotIndex || oneIndex == randomEndSlotIndex || oneIndex == randomStartSlotIndex + 1 || oneIndex == randomStartSlotIndex - 1 || oneIndex == randomStartSlotIndex + 15 || oneIndex == randomEndSlotIndex - 1 || oneIndex == randomEndSlotIndex + 1 || oneIndex == randomEndSlotIndex - 15 {
            print("inwhileloop")
            oneIndex = Int(arc4random_uniform(224))
            print("TRY")
            print(oneIndex)
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
                print(oneIndex)
                let tile = Tile()
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
    
    @objc private func tapTile(_ gesture: UIPanGestureRecognizer) {
        for tile in allTiles {
            if tile.frame.contains(gesture.location(in: view)) && !tile.isLockedInPlace {
                movingTile = tile
            }
        }
    }
    
    
    @objc private func moveTile(_ gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            print("BEGAN")
            for tile in allTiles {
                print(tile.isLockedInPlace)
                if tile.frame.contains(gesture.location(in: view)) && !tile.isLockedInPlace {
                    print("FOUNDONE")
                    movingTile = tile
                    movingTile?.mySize = .large
                    //isNotSameTile = true
                    if movingTile?.slotsIndex != nil {
                        myBoard.slots[(movingTile?.slotsIndex!)!].isOccupied = false
                    }
                }
                if tile.frame.contains(gesture.location(in: myBoard)) && !tile.isLockedInPlace {
                    print("FOUNDONE")
                    movingTile = tile
                    movingTile?.mySize = .large
                    //isNotSameTile = true
                    if movingTile?.slotsIndex != nil {
                        myBoard.slots[(movingTile?.slotsIndex!)!].isOccupied = false
                    }
                }
            }
        case .changed:
            
            if movingTile != nil {
                let translation = gesture.translation(in: view)
                movingTile?.center = CGPoint(x: (movingTile?.center.x)! + translation.x, y: (movingTile?.center.y)! + translation.y)
                gesture.setTranslation(CGPoint(x:0,y:0), in: self.view)
            }
        case .ended:
            if movingTile != nil {
                var ct = 0
                outer: for slotView in myBoard.slots {
                    if slotView.frame.contains(gesture.location(in: myBoard)) && !slotView.isOccupied {
                        slotView.isOccupied = true
                        movingTile?.slotsIndex = ct
                       // movingTile?.mySize = .small
                        movingTile?.myWhereInPlay = .board
                        movingTile?.row = slotView.row
                        movingTile?.column = slotView.column
                        
                      //  zoomInToBoard(point: slotView.center)
                        myBoard.zoomIn()
                        Set.isZoomed = true
                        for tile in allTiles {
                        dropTileWhereItBelongs(tile: tile)
                        }
                        refreshSizes()
                        movingTile = nil
                        break outer
                    }
                    ct += 1
                    if ct == 225 {
                        //make it belong back in atBat
                        dropTileWhereItBelongs(tile: movingTile!)}
                }
            }
        default:
            break
        }
        
        
    }
    
//    func zoomInToBoard(point: CGPoint) {
//        myBoard.zoomScale = 2.0
//    }
//    
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return myBoard.v
//    }
    
 
    
    func dropTileWhereItBelongs(tile: Tile) {
        switch tile.myWhereInPlay {
        case .board:
            tile.removeFromSuperview()
            myBoard.addSubview(tile)
            let row = tile.row!
            let column = tile.column!
            var x = 0.5*sw/375 + CGFloat(column)*23*sw/375
            var y = 0.5*sw/375 + CGFloat(row)*23*sw/375
            if Set.isZoomed {
                let scale = myBoard.scale
                x = scale*(0.5*sw/375 + CGFloat(column)*23*sw/375)
                y = scale*(0.5*sw/375 + CGFloat(row)*23*sw/375)
            }
            tile.frame.origin = CGPoint(x: x, y: y)
            
        case .atBat:
            let order = tile.atBatTileOrder!
            let x = 13*self.sw/375 + CGFloat(order)*50*self.sw/375
            let y = 13*self.sh/667 + myBoard.frame.maxY
            UIView.animate(withDuration: 1.0) {
                tile.frame.origin = CGPoint(x: x, y: y)
            }
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
            case 3:
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
            case 4:
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
            case 5...14:
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
            case .onDeck:
                tile.mySize = .medium
            case .board:
                tile.mySize = .small
                if Set.isZoomed {
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
    
}

