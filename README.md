# JChessEngine

This is easy to use, chess-engine only. 

Primary use is to validate the moves.

## Usage

```swift
let game = Game()
game.make(move: "d4")
```

or using the `Move` class

```swift
let game = Game()
game.make(move: Move(from: "d2", to: "d4"))
```

---

## Adding to your project

Just search for it in Xcode via URL [https://github.com/asgarov1/jchessengine.git](https://github.com/asgarov1/jchessengine.git) and add it as package
