//
//  CoordinateUtil.swift
//  JChessEngine
//
//  Created by Javid Asgarov on 14.01.26.
//
public final class CoordinateUtil {
    public static func squareIndex(_ algebraic: String) -> Int {
        precondition(algebraic.count == 2, "Invalid algebraic notation")

        let chars = Array(algebraic.lowercased())
        let fileChar = chars[0]
        let rankChar = chars[1]

        precondition(fileChar >= "a" && fileChar <= "h", "Invalid file")
        precondition(rankChar >= "1" && rankChar <= "8", "Invalid rank")

        let file = Int(fileChar.asciiValue! - Character("a").asciiValue!)
        let rank = Int(rankChar.asciiValue! - Character("1").asciiValue!)

        return rank * 8 + file
    }
}
