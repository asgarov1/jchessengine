

import Foundation

public enum MoveType {
    case normal
    case castleKingSide
    case castleQueenSide
}
/// A Chess Move representation, with from and to using board index
/// Here is a table of which index matches to which algebraic notation
///
///  0  = a1   1  = b1    2  = c1    3  = d1    4  = e1    5  = f1    6  = g1    7  = h1
///  8  = a2   9  = b2   10 = c2   11 = d2   12 = e2   13 = f2   14 = g2   15 = h2
/// 16 = a3   17 = b3   18 = c3   19 = d3   20 = e3   21 = f3   22 = g3   23 = h3
/// 24 = a4   25 = b4   26 = c4   27 = d4   28 = e4   29 = f4   30 = g4   31 = h4
/// 32 = a5   33 = b5   34 = c5   35 = d5   36 = e5   37 = f5   38 = g5   39 = h5
/// 40 = a6   41 = b6   42 = c6   43 = d6   44 = e6   45 = f6   46 = g6   47 = h6
/// 48 = a7   49 = b7   50 = c7   51 = d7   52 = e7   53 = f7   54 = g7   55 = h7
/// 56 = a8   57 = b8   58 = c8   59 = d8   60 = e8   61 = f8   62 = g8   63 = h8
public struct Move {
    public let from: Int
    public let to: Int
    public let type: MoveType
    
    public init(from: Int, to: Int) {
        self.from = from
        self.to = to
        self.type = .normal
    }
    
    public init(from: Int, to: Int, type: MoveType = .normal) {
        self.from = from
        self.to = to
        self.type = type
    }
    
    public init(from: String, to: String, type: MoveType = .normal) {
        self.from = Move.squareIndex(from)
        self.to = Move.squareIndex(to)
        self.type = type
    }
    
    public init(san: String, board: Board) {
        let stripped = san
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: "#", with: "")

        // --- Castling ---
        if stripped == "O-O" || stripped == "0-0" {
            let kingFrom = board.kingSquare(of: board.sideToMove)
            self.from = kingFrom
            self.to = kingFrom + 2
            self.type = .castleKingSide
            return
        }

        if stripped == "O-O-O" || stripped == "0-0-0" {
            let kingFrom = board.kingSquare(of: board.sideToMove)
            self.from = kingFrom
            self.to = kingFrom - 2
            self.type = .castleQueenSide
            return
        }

        let parsed = SanParser.parse(stripped)

        self = MoveResolver.resolve(
            parsed: parsed,
            board: board
        )
    }

    
    public static func squareIndex(_ s: String) -> Int {
        let chars = Array(s.lowercased())
        let file = Int(chars[0].unicodeScalars.first!.value - Character("a").unicodeScalars.first!.value)
        let rank = Int(chars[1].unicodeScalars.first!.value - Character("1").unicodeScalars.first!.value)
        return rank * 8 + file
    }
}
