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
    
    static func resolve(san: String, board: Board) throws -> Move {
        let parsedSan = SanParser.parse(san)
        return try MoveResolver.resolve(parsed: parsedSan, board: board)
    }
    
    static func resolve(parsed: ParsedSAN, board: Board) throws -> Move {
        let color = board.sideToMove
        
        var moves: [Move] = []
        
        for from in 0..<64 {
            guard let piece = board.squares[from],
                  piece.color == color,
                  piece.type == parsed.pieceType else { continue }
            
            let file = from % 8
            let rank = from / 8
            
            if let df = parsed.disambiguationFile, df != file { continue }
            if let dr = parsed.disambiguationRank, dr != rank { continue }
            
            let move = Move(from: from, to: parsed.to)
            
            if MoveValidator.isLegal(move: move, on: board) {
                moves.append(move)
            }
        }
        
        switch moves.count {
        case 1:
            return moves[0]
        case 0:
            throw SANResolutionError.noMatchingMove(parsed.originalSan)
        default:
            throw SANResolutionError.ambiguousMove(
                parsed.originalSan,
                candidates: moves
            )
        }
    }
}
