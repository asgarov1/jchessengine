//
//  MoveResolver.swift
//  JChessEngine
//
//  Created by Javid Asgarov on 14.01.26.
//

public enum MoveResolutionError: Error {
    case illegal
    case ambiguous
    case notFound
}

public enum MoveResolver {

    public static func resolve(san: String, board: Board) throws -> Move {
        let parsedSan = try SanParser.parse(san)
        return try resolve(parsed: parsedSan, board: board)
    }

    static func resolve(parsed: ParsedSAN, board: Board) throws -> Move {

        let color = board.sideToMove

        // =====================================================
        // CASTLING (early exit)
        // =====================================================
        if let moveType = parsed.moveType,
           moveType == .castleKingSide || moveType == .castleQueenSide {

            let kingFrom: Int
            let kingTo: Int
            let rookFrom: Int
            let rookTo: Int

            switch (color, moveType) {

            case (.white, .castleKingSide):
                kingFrom = 4    // e1
                kingTo   = 6    // g1
                rookFrom = 7    // h1
                rookTo   = 5    // f1

            case (.white, .castleQueenSide):
                kingFrom = 4    // e1
                kingTo   = 2    // c1
                rookFrom = 0    // a1
                rookTo   = 3    // d1

            case (.black, .castleKingSide):
                kingFrom = 60   // e8
                kingTo   = 62   // g8
                rookFrom = 63   // h8
                rookTo   = 61   // f8

            case (.black, .castleQueenSide):
                kingFrom = 60   // e8
                kingTo   = 58   // c8
                rookFrom = 56   // a8
                rookTo   = 59   // d8

            default:
                throw MoveResolutionError.illegal
            }

            guard MoveValidator.isLegalCasting(
                kingFrom: kingFrom,
                kingTo: kingTo,
                rookFrom: rookFrom,
                rookTo: rookTo,
                on: board
            ) else {
                throw MoveResolutionError.illegal
            }

            return Move(
                from: kingFrom,
                to: kingTo,
                san: parsed.originalSan,
                type: moveType
            )
        }

        // =====================================================
        // NORMAL SAN RESOLUTION
        // =====================================================
        guard let to = parsed.to else {
            throw MoveResolutionError.illegal
        }

        var candidates: [Move] = []

        for from in 0..<64 {

            guard
                let piece = board.squares[from],
                piece.color == color,
                piece.type == parsed.pieceType
            else { continue }

            let file = from % 8
            let rank = from / 8

            if let df = parsed.disambiguationFile, df != file { continue }
            if let dr = parsed.disambiguationRank, dr != rank { continue }

            let move = Move(
                from: from,
                to: to,
                san: parsed.originalSan,
                type: parsed.moveType ?? .normal
            )

            if MoveValidator.isLegal(
                from: move.from,
                to: move.to,
                type: move.type,
                on: board
            ) {
                candidates.append(move)
            }
        }

        // =====================================================
        // FINAL SELECTION
        // =====================================================
        switch candidates.count {
        case 1:
            return candidates[0]

        case 0:
            throw SANResolutionError.noMatchingMove(parsed.originalSan)

        default:
            throw SANResolutionError.ambiguousMove(
                parsed.originalSan,
                candidates: candidates
            )
        }
    }
}
