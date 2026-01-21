//
//  SanUtil.swift
//  JChessEngine
//
//  Created by Javid Asgarov on 21.01.26.
//
public final class SanUtil {
    public static func san(for move: Move, on board: Board) -> String {
        return san(from: move.from, to: move.to, type: move.type, on: board)
    }
    
    public static func san(from: String, to: String, type: MoveType, on board: Board) -> String {
        return san(from: MoveUtil.squareIndex(from), to: MoveUtil.squareIndex(to), type: type, on: board)
    }
    
    public static func san(from: String, to: String, on board: Board) -> String {
        return san(from: MoveUtil.squareIndex(from), to: MoveUtil.squareIndex(to), type: .normal, on: board)
    }
    
    public static func san(from: Int, to: Int, type: MoveType, on board: Board) -> String {
        guard let piece = board.squares[from] else {
            return ""
        }
        
        // --- Castling ---
        switch type {
        case .castleKingSide:
            return withCheckSuffix("O-O", from: from, to: to, moveType: type, board: board)
        case .castleQueenSide:
            return withCheckSuffix("O-O-O", from: from, to: to, moveType: type, board: board)
        default:
            break
        }
        
        let target = board.squares[to]
        var san = ""
        
        // --- Piece letter (pawn has none) ---
        if piece.type != .pawn {
            san.append(piece.type.sanLetter)
        }
        
        // --- Disambiguation ---
        if piece.type != .pawn {
            let ambiguous = ambiguousSources(from: from, to: to, type: type, piece: piece, board: board)
            
            if ambiguous.count > 1 {
                let fromFile = file(of: from)
                let fromRank = rank(of: from)
                
                if ambiguous.allSatisfy({ file(of: $0) != fromFile }) {
                    san.append(fromFile)
                } else if ambiguous.allSatisfy({ rank(of: $0) != fromRank }) {
                    san.append(fromRank)
                } else {
                    san.append(fromFile)
                    san.append(fromRank)
                }
            }
        }
        
        // --- Capture ---
        if target != nil {
            if piece.type == .pawn {
                san.append(file(of: from))
            }
            san.append("x")
        }
        
        // --- Destination ---
        san.append(squareName(to))
        
        // --- Promotion ---
        // TODO implement
        
        return withCheckSuffix(san, from: from, to: to, moveType: type, board: board)
    }
    
    // MARK: - Helpers (reuse engine logic)
    
    private static func ambiguousSources(
        from: Int,
        to: Int,
        type: MoveType,
        piece: Piece,
        board: Board
    ) -> [Int] {
        (0..<64).filter { from in
            guard from != from else { return false }
            guard let other = board.squares[from] else { return false }
            guard other.type == piece.type,
                  other.color == piece.color else { return false }
            
            return MoveValidator.isLegal(from: from, to: to, type: type, on: board)
        }
    }
    
    private static func withCheckSuffix(
        _ san: String,
        from: Int,
        to: Int,
        moveType: MoveType,
        board: Board
    ) -> String {
        var testBoard = board.copy()
        apply(from: from, to: to, on: &testBoard)
        
        let enemy = testBoard.sideToMove
        let kingSquare = testBoard.kingSquare(of: enemy)
        
        if AttackDetector.isSquareAttacked(
            kingSquare,
            by: enemy.opposite,
            board: testBoard
        ) {
            if isCheckmate(from: from, to: to, moveType: moveType, on: testBoard) {
                return san + "#"
            }
            return san + "+"
        }
        
        return san
    }
    
    private static func isCheckmate(from: Int, to: Int, moveType: MoveType, on board: Board) -> Bool {
        let color = board.sideToMove
        
        for from in 0..<64 {
            guard let piece = board.squares[from],
                  piece.color == color else { continue }
            
            for to in 0..<64 {
                if MoveValidator.isLegalForCheckmateSearch(from: from, to: to, on: board) {
                    return false
                }
            }
        }
        return true
    }
    
    private static func apply(from: Int, to: Int, on board: inout Board) {
        board.squares[to] = board.squares[from]
        board.squares[from] = nil
        board.sideToMove = board.sideToMove.opposite
    }
    
    private static func file(of index: Int) -> String {
        String(UnicodeScalar(Int(Character("a").unicodeScalars.first!.value) + index % 8)!)
    }
    
    private static func rank(of index: Int) -> String {
        String(index / 8 + 1)
    }
    
    private static func squareName(_ index: Int) -> String {
        file(of: index) + rank(of: index)
    }
}
