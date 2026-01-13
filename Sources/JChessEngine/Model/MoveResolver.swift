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

    public static func resolve(
        algebraic: AlgebraicMove,
        board: Board
    ) throws -> Move {

        // Castling
        if let castle = algebraic.castling {
            let from = board.sideToMove == .white ? 4 : 60
            let to = castle == .castleKingSide
                ? (board.sideToMove == .white ? 6 : 62)
                : (board.sideToMove == .white ? 2 : 58)

            let move = Move(from: from, to: to, type: castle)
            guard MoveValidator.isLegal(move: move, on: board) else {
                throw MoveResolutionError.illegal
            }
            return move
        }

        var candidates: [Int] = []

        for from in 0..<64 {
            guard let p = board.squares[from],
                  p.color == board.sideToMove,
                  p.type == algebraic.piece else { continue }

            let move = Move(from: from, to: algebraic.destination)
            if MoveValidator.isLegal(move: move, on: board) {
                candidates.append(from)
            }
        }

        let filtered = candidates.filter { sq in
            if let f = algebraic.fileHint, sq % 8 != f { return false }
            if let r = algebraic.rankHint, sq / 8 != r { return false }
            return true
        }

        guard filtered.count == 1 else {
            throw filtered.isEmpty
                ? MoveResolutionError.notFound
                : MoveResolutionError.ambiguous
        }

        return Move(from: filtered[0], to: algebraic.destination)
    }
}
