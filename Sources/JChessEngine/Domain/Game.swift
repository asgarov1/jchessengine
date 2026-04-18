
public enum GameResult: Equatable {
    case ongoing
    case checkmate(winner: Color)
    case stalemate
}

/// A class to represent a Chess Game
public final class Game {
    public internal(set) var board: Board

    public init() {
        board = Board(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    }
    
    public init(fen: String) {
        board = Board(fen: fen)
    }
    
    public func make(from: String, to: String, type: MoveType = .normal) throws -> Bool {
        let fromInt = MoveUtil.squareIndex(from)
        let toInt = MoveUtil.squareIndex(to)
        return try make(from: fromInt, to: toInt, type: type)
    }
    
    public func make(from: Int, to: Int, type: MoveType = .normal) throws -> Bool {
        let san = SanUtil.san(from: from, to: to, type: .normal, on: self.board)
        guard !san.isEmpty else {
            return false
        }
        return try make(move: san)
    }
    
    /// "san" meaning Standard Algebraic Notation
    /// Allows making a move with algebraic notation only
    public func make(move san: String) throws -> Bool {
        let resolved: Move = try MoveResolver.resolve(san: san, board: board)
        return make(move: resolved)
    }
    
    public func make(move: Move) -> Bool {
        guard MoveValidator.isLegal(from: move.from, to: move.to, type: move.type, on: board) else { return false }

        let piece = board.squares[move.from]
        board.squares[move.from] = nil
        board.squares[move.to] = piece

        // Castling: the king has moved above — the rook also needs to be relocated.
        if move.type == .castleKingSide || move.type == .castleQueenSide {
            let rank = board.sideToMove == .white ? 0 : 7
            let rookFrom: Int
            let rookTo: Int
            if move.type == .castleKingSide {
                rookFrom = rank * 8 + 7 // h1 / h8
                rookTo   = rank * 8 + 5 // f1 / f8
            } else {
                rookFrom = rank * 8 + 0 // a1 / a8
                rookTo   = rank * 8 + 3 // d1 / d8
            }
            board.squares[rookTo] = board.squares[rookFrom]
            board.squares[rookFrom] = nil
        }

        if piece?.type == .king {
            if board.sideToMove == .white {
                board.castlingRights.whiteKingSide = false
                board.castlingRights.whiteQueenSide = false
            } else {
                board.castlingRights.blackKingSide = false
                board.castlingRights.blackQueenSide = false
            }
        }

        if piece?.type == .rook {
            if move.from == 0 { board.castlingRights.whiteQueenSide = false }
            if move.from == 7 { board.castlingRights.whiteKingSide = false }
            if move.from == 56 { board.castlingRights.blackQueenSide = false }
            if move.from == 63 { board.castlingRights.blackKingSide = false }
        }

        board.sideToMove = board.sideToMove.opposite

        // only after the move was successfully made
        board.moveHistory.append(move)
        return true
    }
    
    public func fen() -> String {
        FEN.export(board: board)
    }
    
    public func gameResult() -> GameResult {
        for from in 0..<64 {
            guard let piece = board.squares[from],
                  piece.color == board.sideToMove else { continue }
            
            for to in 0..<64 {
                for type in MoveType.allCases {
                    if MoveValidator.isLegal(from: from, to: to, type: type, on: board) {
                        return .ongoing
                    }
                }
            }
        }
        
        if isKingInCheck(color: board.sideToMove) {
            return .checkmate(winner: board.sideToMove.opposite)
        } else {
            return .stalemate
        }
    }
    
    public func isKingInCheck(color: Color) -> Bool {
        let kingSquare = board.kingSquare(of: color)
        return AttackDetector.isSquareAttacked(
            kingSquare,
            by: color.opposite,
            board: board
        )
    }
    
    public func pgn() -> String {
        var result: [String] = []
        var moveNumber = 1

        for (index, move) in board.moveHistory.enumerated() {
            // White move
            if index % 2 == 0 {
                result.append("\(moveNumber).")
            }

            result.append(move.san ?? "")

            if index % 2 == 1 {
                moveNumber += 1
            }
        }

        return result.joined(separator: " ")
    }
}
