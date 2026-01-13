
public enum MoveValidator {

    public static func isLegal(move: Move, on board: Board) -> Bool {
        guard let piece = board.squares[move.from] else { return false }
        if piece.color != board.sideToMove { return false }

        switch move.type {
        case .castleKingSide:
            return canCastle(kingSide: true, board: board)
        case .castleQueenSide:
            return canCastle(kingSide: false, board: board)
        case .normal:
            return basicMovement(piece: piece, move: move)
        }
    }

    private static func basicMovement(piece: Piece, move: Move) -> Bool {
        let dx = abs((move.from % 8) - (move.to % 8))
        let dy = abs((move.from / 8) - (move.to / 8))

        switch piece.type {
        case .rook: return dx == 0 || dy == 0
        case .bishop: return dx == dy
        case .queen: return dx == dy || dx == 0 || dy == 0
        case .knight: return (dx == 1 && dy == 2) || (dx == 2 && dy == 1)
        case .king: return dx <= 1 && dy <= 1
        case .pawn: return dx == 0 && dy == 1
        }
    }

    private static func canCastle(kingSide: Bool, board: Board) -> Bool {
        let color = board.sideToMove
        let rank = (color == .white) ? 0 : 7
        let kingSquare = rank * 8 + 4

        let rightsOK = kingSide
            ? (color == .white ? board.castlingRights.whiteKingSide : board.castlingRights.blackKingSide)
            : (color == .white ? board.castlingRights.whiteQueenSide : board.castlingRights.blackQueenSide)

        if !rightsOK { return false }

        let between = kingSide ? [5,6] : [1,2,3]
        for f in between {
            let sq = rank * 8 + f
            if board.squares[sq] != nil { return false }
            if AttackDetector.isSquareAttacked(sq, by: color.opposite, board: board) {
                return false
            }
        }

        if AttackDetector.isSquareAttacked(kingSquare, by: color.opposite, board: board) {
            return false
        }

        return true
    }
}
