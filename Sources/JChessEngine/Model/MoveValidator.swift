
public enum MoveValidator {
    
    static func isLegalCasting(
            kingFrom: Int,
            kingTo: Int,
            rookFrom: Int,
            rookTo: Int,
            on board: Board
        ) -> Bool {

            guard
                let king = board.squares[kingFrom],
                let rook = board.squares[rookFrom],
                king.type == .king,
                rook.type == .rook,
                king.color == rook.color
            else {
                return false
            }

            // King or rook already moved
            if board.hasMoved(square: kingFrom) || board.hasMoved(square: rookFrom) {
                return false
            }

            let color = king.color

            // King currently in check
            if AttackDetector.isSquareAttacked(kingFrom, by: king.color.opposite, board: board) {
                return false
            }

            let step = kingTo > kingFrom ? 1 : -1

            // Squares king crosses (including destination)
            var square = kingFrom + step
            while square != kingTo + step {
                // Must be empty (except rook start square)
                if square != rookFrom && board.squares[square] != nil {
                    return false
                }

                // King may not pass through or land on attacked squares
                if AttackDetector.isSquareAttacked(square, by: king.color.opposite, board: board) {
                    return false
                }

                square += step
            }

            return true
        }
    
    public static func isLegal(from: String, to: String, on board: Board) -> Bool {
        return isLegal(from: MoveUtil.squareIndex(from), to: MoveUtil.squareIndex(to), type: .normal, on: board)
    }
    
    public static func isLegal(from: String, to: String, type: MoveType, on board: Board) -> Bool {
        return isLegal(from: MoveUtil.squareIndex(from), to: MoveUtil.squareIndex(to), type: type, on: board)
    }
    
    public static func isLegal(from: Int, to: Int, type: MoveType, on board: Board) -> Bool {
        guard let piece = board.squares[from] else { return false }
        if piece.color != board.sideToMove { return false }
        
        let target = board.squares[to]
        
        // cannot capture own piece
        if let target, target.color == piece.color {
            return false
        }
        
        // Step 1: movement validation
        let moveIsValid: Bool
        
        switch type {
            
        case .castleKingSide:
            moveIsValid = canCastle(kingSide: true, board: board)
            
        case .castleQueenSide:
            moveIsValid = canCastle(kingSide: false, board: board)
            
        case .normal:
            guard basicMovement(from: from, to: to, piece: piece, target: target, board: board) else {
                return false
            }
            
            if piece.type.isSliding {
                guard MoveUtil.isPathClear(from: from, to: to, board: board) else {
                    return false
                }
            }
            
            moveIsValid = true
        }
        
        if !moveIsValid { return false }
        
        // Step 2: king safety (APPLIES TO ALL MOVE TYPES)
        return doesNotLeaveKingInCheck(from: from, to: to, board: board)
    }
    
    public static func isLegalForCheckmateSearch(
        from: Int,
        to: Int,
        on board: Board
    ) -> Bool {
        guard let piece = board.squares[from],
              piece.color == board.sideToMove else {
            return false
        }

        let target = board.squares[to]
        if let target, target.color == piece.color {
            return false
        }

        guard basicMovement(from: from, to: to, piece: piece, target: target, board: board) else {
            return false
        }

        if piece.type.isSliding {
            guard MoveUtil.isPathClear(from: from, to: to, board: board) else {
                return false
            }
        }

        // simulate move
        var testBoard = board.copy()
        testBoard.squares[to] = testBoard.squares[from]
        testBoard.squares[from] = nil

        return !AttackDetector.isSquareAttacked(
            testBoard.kingSquare(of: board.sideToMove),
            by: board.sideToMove.opposite,
            board: testBoard
        )
    }

    
    
    private static func basicMovement(
        from: Int,
        to: Int,
        piece: Piece,
        target: Piece?,
        board: Board
    ) -> Bool {
        
        let fromFile = from % 8
        let fromRank = from / 8
        let toFile = to % 8
        let toRank = to / 8
        
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
            let startRank = piece.color == .white ? 1 : 6
            
            // capture
            if target != nil {
                return dx == 1 && (toRank - fromRank) == direction
            }
            
            // single push
            if dx == 0 && (toRank - fromRank) == direction {
                return true
            }
            
            // double push from starting position
            if dx == 0 &&
                fromRank == startRank &&
                (toRank - fromRank) == 2 * direction {
                
                let intermediateRank = fromRank + direction
                let intermediateSquare = intermediateRank * 8 + fromFile
                
                return board.squares[intermediateSquare] == nil
            }
            
            return false
        }
    }
    
    private static func canCastle(kingSide: Bool, board: Board) -> Bool {
        let color = board.sideToMove
        let rank = (color == .white) ? 0 : 7

        let kingFrom = rank * 8 + 4
        let rookFrom = rank * 8 + (kingSide ? 7 : 0)

        // 1️⃣ Castling rights
        let rightsOK = kingSide
            ? (color == .white
                ? board.castlingRights.whiteKingSide
                : board.castlingRights.blackKingSide)
            : (color == .white
                ? board.castlingRights.whiteQueenSide
                : board.castlingRights.blackQueenSide)

        if !rightsOK { return false }

        // 2️⃣ King and rook must exist
        guard
            let king = board.squares[kingFrom],
            let rook = board.squares[rookFrom],
            king.type == .king,
            rook.type == .rook,
            king.color == color,
            rook.color == color
        else {
            return false
        }

        // 3️⃣ Squares between must be empty
        let emptyFiles = kingSide ? [5, 6] : [1, 2, 3]
        for f in emptyFiles {
            if board.squares[rank * 8 + f] != nil {
                return false
            }
        }

        // 4️⃣ King may not be in check initially
        if AttackDetector.isSquareAttacked(kingFrom, by: color.opposite, board: board) {
            return false
        }

        // 5️⃣ Simulate king stepping through castling squares
        let step = kingSide ? 1 : -1
        var testBoard = board.copy()

        var currentKingSquare = kingFrom

        for _ in 0..<2 {
            let nextSquare = currentKingSquare + step

            // simulate king move
            testBoard.squares[nextSquare] = testBoard.squares[currentKingSquare]
            testBoard.squares[currentKingSquare] = nil

            if AttackDetector.isSquareAttacked(nextSquare, by: color.opposite, board: testBoard) {
                return false
            }

            // restore for next iteration
            testBoard.squares[currentKingSquare] = testBoard.squares[nextSquare]
            testBoard.squares[nextSquare] = nil

            currentKingSquare = nextSquare
        }

        return true
    }

    
    private static func doesNotLeaveKingInCheck(from: Int, to: Int, board: Board) -> Bool {
        guard let piece = board.squares[from] else { return false }

        let colorToMove = board.sideToMove

        // ✅ FIXED king handling
        if piece.type == .king {
            var testBoard = board.copy()
            testBoard.squares[to] = testBoard.squares[from]
            testBoard.squares[from] = nil

            return !AttackDetector.isSquareAttacked(
                to,
                by: colorToMove.opposite,
                board: testBoard
            )
        }

        // simulate move for non-king pieces
        var testBoard = board.copy()
        testBoard.squares[to] = testBoard.squares[from]
        testBoard.squares[from] = nil

        return !AttackDetector.isSquareAttacked(
            testBoard.kingSquare(of: colorToMove),
            by: colorToMove.opposite,
            board: testBoard
        )
    }

}
