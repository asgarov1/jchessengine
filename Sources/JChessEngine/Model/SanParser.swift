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
    /// Promotion piece extracted from a `=Q` / `=N` / `=R` / `=B` suffix.
    /// `nil` if no suffix was present. Auto-queen fallback is applied later in `Game.make`.
    let promotionPiece: PieceType?
}

enum SanParser {

    static func parse(_ rawSan: String) throws -> ParsedSAN {
        // Strip check (`+`) and checkmate (`#`) markers up front so every
        // call path into the parser behaves the same. `Move.init(san:board:)`
        // used to do this itself; doing it here means `Game.make(move: "e4+")`
        // (which goes through `MoveResolver.resolve(san:)`) works too.
        let san = rawSan
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: "#", with: "")

        // --- CASTLING (early exit) ---
        if san == "O-O" || san == "0-0" {
            return ParsedSAN(
                originalSan: rawSan,
                pieceType: .king,
                to: nil,
                disambiguationFile: nil,
                disambiguationRank: nil,
                isCapture: false,
                moveType: .castleKingSide,
                promotionPiece: nil
            )
        }

        if san == "O-O-O" || san == "0-0-0" {
            return ParsedSAN(
                originalSan: rawSan,
                pieceType: .king,
                to: nil,
                disambiguationFile: nil,
                disambiguationRank: nil,
                isCapture: false,
                moveType: .castleQueenSide,
                promotionPiece: nil
            )
        }

        // --- NORMAL SAN PARSING ---
        // Extract optional promotion suffix (e.g. "=Q") before parsing the
        // destination square. `=` is the PGN standard separator. If no suffix
        // is present we leave promotionPiece as nil — Game.make will auto-queen.
        var sanForParsing = san
        var promotionPiece: PieceType? = nil
        if let equalIndex = sanForParsing.firstIndex(of: "=") {
            let afterEqual = sanForParsing[sanForParsing.index(after: equalIndex)...]
            guard let promoChar = afterEqual.first else {
                throw SANResolutionError.illegalMove(san)
            }
            switch promoChar {
            case "Q": promotionPiece = .queen
            case "R": promotionPiece = .rook
            case "B": promotionPiece = .bishop
            case "N": promotionPiece = .knight
            default:
                throw SANResolutionError.illegalMove(san)
            }
            sanForParsing = String(sanForParsing[..<equalIndex])
        }

        let destination = String(sanForParsing.suffix(2))
        guard destination.count == 2,
              let fileChar = destination.first,
              let rankChar = destination.last,
              fileChar >= "a", fileChar <= "h",
              rankChar >= "1", rankChar <= "8"
        else {
            throw SANResolutionError.illegalMove(san)
        }

        let to = MoveUtil.squareIndex(destination)

        var body = String(sanForParsing.dropLast(2))
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
            originalSan: rawSan,
            pieceType: pieceType,
            to: to,
            disambiguationFile: disFile,
            disambiguationRank: disRank,
            isCapture: isCapture,
            moveType: .normal,
            promotionPiece: promotionPiece
        )
    }
}
