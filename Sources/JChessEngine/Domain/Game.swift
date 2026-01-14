
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
        let algebraic = try AlgebraicParser.parse(san)
        let resolved = try MoveResolver.resolve(algebraic: algebraic, board: board)
        return make(move: resolved)
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
}
