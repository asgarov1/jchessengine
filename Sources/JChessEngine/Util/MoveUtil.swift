//
//  MovementUtil.swift
//  JChessEngine
//
//  Created by Javid Asgarov on 14.01.26.
//
public final class MoveUtil {
    
    public static func isPathClear(from: Int, to: Int, board: Board) -> Bool {
        let fromFile = from % 8
        let fromRank = from / 8
        let toFile = to % 8
        let toRank = to / 8

        let df = toFile - fromFile
        let dr = toRank - fromRank

        let stepFile = df.signum()
        let stepRank = dr.signum()

        // ✅ Reject invalid directions immediately
        // Must be rook or bishop line
        if !(df == 0 || dr == 0 || abs(df) == abs(dr)) {
            return false
        }

        var file = fromFile + stepFile
        var rank = fromRank + stepRank

        while file != toFile || rank != toRank {
            // ✅ Bounds check (CRITICAL)
            guard file >= 0, file < 8, rank >= 0, rank < 8 else {
                return false
            }

            let sq = rank * 8 + file
            if board.squares[sq] != nil {
                return false
            }

            file += stepFile
            rank += stepRank
        }

        return true
    }

    
    public static func squareIndex(_ s: String) -> Int {
        let chars = Array(s.lowercased())
        let file = Int(chars[0].unicodeScalars.first!.value - Character("a").unicodeScalars.first!.value)
        let rank = Int(chars[1].unicodeScalars.first!.value - Character("1").unicodeScalars.first!.value)
        return rank * 8 + file
    }
    
    public static func toCoordinate(_ index: Int) -> String {
        let file = index % 8
        let rank = index / 8
        let fileChar = Character(UnicodeScalar(97 + file)!)
        return "\(fileChar)\(rank + 1)"
    }
}
