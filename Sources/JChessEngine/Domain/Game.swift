
public enum GameResult: Equatable {
    case ongoing
    case checkmate(winner: Color)
    case stalemate
}

/// A class to represent a Chess Game
public final class Game {
    public private(set) var board: Board
    
    public init() {
        board = Board(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    }
    
    public init(fen: String) {
        board = Board(fen: fen)
    }
    
    /// "san" meaning Standard Algebraic Notation
    /// Allows making a move with algebraic notation only
    public func make(move san: String) throws -> Bool {
        let resolved: Move = try MoveResolver.resolve(san: san, board: board)
        return make(move: resolved)
    }
    
    public func make(from: String, to: String) throws -> Bool {
        return make(move: Move(from: from, to: to))
    }
    
    public func make(move: Move) -> Bool {
        guard MoveValidator.isLegal(move: move, on: board) else { return false }
        
        let piece = board.squares[move.from]
        board.squares[move.from] = nil
        board.squares[move.to] = piece
        
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
                let move = Move(from: from, to: to)
                if MoveValidator.isLegal(move: move, on: board) {
                    return .ongoing
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
    
}
