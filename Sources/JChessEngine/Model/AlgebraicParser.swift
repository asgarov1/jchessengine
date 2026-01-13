//
//  AlgebraicParser.swift
//  JChessEngine
//
//  Created by Javid Asgarov on 14.01.26.
//
import Foundation

public enum AlgebraicParser {

    public static func parse(_ input: String) throws -> AlgebraicMove {
        let san = input.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        // Castling
        if san == "O-O" {
            return AlgebraicMove(
                piece: .king,
                destination: -1,
                fileHint: nil,
                rankHint: nil,
                isCapture: false,
                promotion: nil,
                castling: .castleKingSide
            )
        }

        if san == "O-O-O" {
            return AlgebraicMove(
                piece: .king,
                destination: -1,
                fileHint: nil,
                rankHint: nil,
                isCapture: false,
                promotion: nil,
                castling: .castleQueenSide
            )
        }

        var chars = Array(san)
        var index = 0

        // Piece
        let piece: PieceType
        if let p = PieceType(rawValue: String(chars[0]).lowercased()),
           chars[0].isUppercase {
            piece = p
            index += 1
        } else {
            piece = .pawn
        }

        var fileHint: Int?
        var rankHint: Int?
        var isCapture = false

        while index < chars.count - 2 {
            let c = chars[index]

            if c == "x" {
                isCapture = true
                index += 1
                continue
            }

            if let f = fileIndex(c) {
                fileHint = f
            } else if let r = rankIndex(c) {
                rankHint = r
            }

            index += 1
        }

        let destFile = fileIndex(chars[chars.count - 2])!
        let destRank = rankIndex(chars[chars.count - 1])!
        let destination = destRank * 8 + destFile

        return AlgebraicMove(
            piece: piece,
            destination: destination,
            fileHint: fileHint,
            rankHint: rankHint,
            isCapture: isCapture,
            promotion: nil,
            castling: nil
        )
    }

    private static func fileIndex(_ c: Character) -> Int? {
        guard let v = c.unicodeScalars.first?.value,
              v >= 97, v <= 104 else { return nil }
        return Int(v - 97)
    }

    private static func rankIndex(_ c: Character) -> Int? {
        guard let v = c.unicodeScalars.first?.value,
              v >= 49, v <= 56 else { return nil }
        return Int(v - 49)
    }
}
