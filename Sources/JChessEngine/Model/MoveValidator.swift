
public enum MoveValidator {

    public static func isLegal(move: Move, on board: Board) -> Bool {
        guard let piece = board.squares[move.from] else { return false }
        if piece.color != board.sideToMove { return false }

        let target = board.squares[move.to]

        // cannot capture own piece
        if let target, target.color == piece.color {
            return false
        }

        // Step 1: movement validation
        let moveIsValid: Bool

        switch move.type {

        case .castleKingSide:
            moveIsValid = canCastle(kingSide: true, board: board)

        case .castleQueenSide:
            moveIsValid = canCastle(kingSide: false, board: board)

        case .normal:
            guard basicMovement(piece: piece, move: move, target: target) else {
                return false
            }

            if piece.type.isSliding {
                guard MovementUtil.isPathClear(from: move.from, to: move.to, board: board) else {
                    return false
                }
            }

            moveIsValid = true
        }

        if !moveIsValid { return false }

        // Step 2: king safety (APPLIES TO ALL MOVE TYPES)
        return doesNotLeaveKingInCheck(move: move, board: board)
    }


    private static func basicMovement(
        piece: Piece,
        move: Move,
        target: Piece?
    ) -> Bool {

        let fromFile = move.from % 8
        let fromRank = move.from / 8
        let toFile = move.to % 8
        let toRank = move.to / 8

        let dx = abs(fromFile - toFile)
        let dy = abs(fromRank - toRank)

        switch piece.type {

        case .rook:
            return dx == 0 || dy == 0

        case .bishop:
            return dx == dy

        case .queen:
            return dx == dy || dx == 0 || dy == 0

        case .knight:
            return (dx == 1 && dy == 2) || (dx == 2 && dy == 1)

        case .king:
            return dx <= 1 && dy <= 1

        case .pawn:
            let direction = piece.color == .white ? 1 : -1

            // capture
            if target != nil {
                return dx == 1 && (toRank - fromRank) == direction
            }

            // quiet move
            return dx == 0 && (toRank - fromRank) == direction
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
    
    private static func doesNotLeaveKingInCheck(move: Move, board: Board) -> Bool {
        guard let piece = board.squares[move.from] else { return false }
        
        let colorToMove = board.sideToMove
        if piece.type == .king {
            // if king is making move check that target is not under check
            return !AttackDetector.isSquareAttacked(
                move.to,
                by: colorToMove.opposite,
                board: board
            )
        }

        // simulateMove
        var testBoard = board.copy()
        testBoard.squares[move.to] = testBoard.squares[move.from]
        testBoard.squares[move.from] = nil
        
        return !AttackDetector.isSquareAttacked(
            testBoard.kingSquare(of: colorToMove),
            by: colorToMove.opposite,
            board: testBoard
        )
    }
}
