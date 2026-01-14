# JChessEngine

This is easy to use, chess-engine only. 

Primary use is to validate the moves.

## Usage

### Starting the game
```swift
let game = Game()
game.make(move: "d4") // make will return false if move is invalid
```

or using the `Move` class

```swift
let game = Game()
game.make(move: Move(from: "d2", to: "d4"))
```

### Exporting FEN
```swift
game.fen()
```

### Validating moves before making them

```swift
let game = Game()
let isLegalMove = MoveValidator.isLegal(move: Move(from: "d2", to: "d4"), on: game.board) 
```
---

## Adding to your project

Just search for it in Xcode via URL [https://github.com/asgarov1/jchessengine.git](https://github.com/asgarov1/jchessengine.git) and add it as package
