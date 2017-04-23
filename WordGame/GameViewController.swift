//
//  ViewController.swift
//  WordGame
//
//  Created by Aaron Halvorsen on 4/21/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    let myColor = CustomColor()
    let myBoard = Board.sharedInstance
    var pan = UIPanGestureRecognizer()
    var allTiles = [Tile]()
    var movingTile = Tile()
    var onDeckTiles = [Tile]()
    let pile = Tile()
    var pileOfTiles = 10 { didSet { pileOfTilesString = String(pileOfTiles); pile.text.text = "x" + pileOfTilesString } }
    var pileOfTilesString = "x10"
    var isNotSameTile = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = myColor.white245
        view.addSubview(myBoard)

        pan = UIPanGestureRecognizer(target: self, action: #selector(GameViewController.moveTile(_:)))
        view.addGestureRecognizer(pan)
        pile.text.font = UIFont(name: "HelveticaNeue-Bold", size: 14*fontSizeMultiplier)
        pile.frame = CGRect(x: 15*sw/375, y: 616*sh/667, width: 34*sw/375, height: 34*sw/375)
        view.addSubview(pile)
        pile.text.text = pileOfTilesString
        addTilesToBoard()
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
    
    
    @objc private func moveTile(_ gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            for tile in allTiles {
                if tile.frame.contains(gesture.location(in: view)) && !tile.isLockedInPlace {
                    movingTile = tile
                    movingTile.mySize = .large
                    isNotSameTile = true
                    if movingTile.slotsIndex != nil {
                        myBoard.slots[movingTile.slotsIndex!].isOcc = false
                    }
                }
            }
        case .changed:
            if isNotSameTile {
            let translation = gesture.translation(in: view)
            movingTile.center = CGPoint(x: movingTile.center.x + translation.x, y: movingTile.center.y + translation.y)
            gesture.setTranslation(CGPoint(x:0,y:0), in: self.view)
            }
        case .ended:
            
            isNotSameTile = false
            var ct = 0
            outer: for (slotView,row,column,isSlotOccupied) in myBoard.slots {
                if slotView.frame.contains(gesture.location(in: myBoard)) && !isSlotOccupied {
                    myBoard.slots[ct].isOcc = true
                    movingTile.slotsIndex = ct
                    movingTile.mySize = .small
                    movingTile.myWhereInPlay = .board
                    movingTile.row = row
                    movingTile.column = column
                    dropTileWhereItBelongs(tile: movingTile)
                    break outer
                }
                ct += 1
                if ct == 225 {
                    //make it belong back in atBat
                    dropTileWhereItBelongs(tile: movingTile)}
                
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
            let x = 0.5*sw/375 + CGFloat(column)*23*sw/375
            let y = 0.5*sw/375 + CGFloat(row)*23*sw/375
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

}

