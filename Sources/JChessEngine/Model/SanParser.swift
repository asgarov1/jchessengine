//
//  Untitled.swift
//  JChessEngine
//
//  Created by Javid Asgarov on 15.01.26.
//
import Foundation

struct ParsedSAN {
    let originalSan: String
    let pieceType: PieceType
    let to: Int?
    let disambiguationFile: Int?
    let disambiguationRank: Int?
    let isCapture: Bool
    let moveType: MoveType?
}

enum SanParser {

    static func parse(_ san: String) throws -> ParsedSAN {
        // --- CASTLING (early exit) ---
        if san == "O-O" || san == "0-0" {
            return ParsedSAN(
                originalSan: san,
                pieceType: .king,
                to: nil,
                disambiguationFile: nil,
                disambiguationRank: nil,
                isCapture: false,
                moveType: .castleKingSide
            )
        }

        if san == "O-O-O" || san == "0-0-0" {
            return ParsedSAN(
                originalSan: san,
                pieceType: .king,
                to: nil,
                disambiguationFile: nil,
                disambiguationRank: nil,
                isCapture: false,
                moveType: .castleQueenSide
            )
        }

        // --- NORMAL SAN PARSING ---
        let destination = String(san.suffix(2))
        guard destination.count == 2,
              let fileChar = destination.first,
              let rankChar = destination.last,
              fileChar >= "a", fileChar <= "h",
              rankChar >= "1", rankChar <= "8"
        else {
            throw SANResolutionError.illegalMove(san)
        }

        let to = MoveUtil.squareIndex(destination)

        var body = String(san.dropLast(2))
        let isCapture = body.contains("x")
        body = body.replacingOccurrences(of: "x", with: "")

        let pieceType: PieceType
        if let c = body.first, c.isUppercase {
            pieceType = PieceType.fromSAN(c)
            body = String(body.dropFirst())
        } else {
            pieceType = .pawn
        }

        var disFile: Int?
        var disRank: Int?

        for c in body {
            if c.isLetter {
                disFile = Int(c.unicodeScalars.first!.value
                              - Character("a").unicodeScalars.first!.value)
            } else if c.isNumber {
                disRank = Int(c.unicodeScalars.first!.value
                              - Character("1").unicodeScalars.first!.value)
            }
        }

        return ParsedSAN(
            originalSan: san,
            pieceType: pieceType,
            to: to,
            disambiguationFile: disFile,
            disambiguationRank: disRank,
            isCapture: isCapture,
            moveType: .normal
        )
    }
}
