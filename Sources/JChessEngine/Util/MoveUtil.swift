//
//  MovementUtil.swift
//  JChessEngine
//
//  Created by Javid Asgarov on 14.01.26.
//
public final class MoveUtil {
    
    public static func isPathClear(from: Int, to: Int, board: Board) -> Bool {
        let fromFile = from % 8
        let fromRank = from / 8
        let toFile = to % 8
        let toRank = to / 8

        let stepFile = (toFile - fromFile).signum()
        let stepRank = (toRank - fromRank).signum()

        var file = fromFile + stepFile
        var rank = fromRank + stepRank

        while file != toFile || rank != toRank {
            let sq = rank * 8 + file
            if board.squares[sq] != nil {
                return false
            }
            file += stepFile
            rank += stepRank
        }

        return true
    }
    
    public static func san(for move: Move, on board: Board) -> String {
           guard let piece = board.squares[move.from] else {
               return ""
           }

           // --- Castling ---
           switch move.type {
           case .castleKingSide:
               return withCheckSuffix("O-O", move: move, board: board)
           case .castleQueenSide:
               return withCheckSuffix("O-O-O", move: move, board: board)
           default:
               break
           }

           let target = board.squares[move.to]
           var san = ""

           // --- Piece letter (pawn has none) ---
           if piece.type != .pawn {
               san.append(piece.type.sanLetter)
           }

           // --- Disambiguation ---
           if piece.type != .pawn {
               let ambiguous = ambiguousSources(for: move, piece: piece, board: board)

               if ambiguous.count > 1 {
                   let fromFile = file(of: move.from)
                   let fromRank = rank(of: move.from)

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
                   san.append(file(of: move.from))
               }
               san.append("x")
           }

           // --- Destination ---
           san.append(squareName(move.to))

           // --- Promotion ---
           // TODO implement

           return withCheckSuffix(san, move: move, board: board)
       }

       // MARK: - Helpers (reuse engine logic)

       private static func ambiguousSources(
           for move: Move,
           piece: Piece,
           board: Board
       ) -> [Int] {
           (0..<64).filter { from in
               guard from != move.from else { return false }
               guard let other = board.squares[from] else { return false }
               guard other.type == piece.type,
                     other.color == piece.color else { return false }

               let testMove = Move(from: from, to: move.to, type: move.type)
               return MoveValidator.isLegal(move: testMove, on: board)
           }
       }

       private static func withCheckSuffix(
           _ san: String,
           move: Move,
           board: Board
       ) -> String {
           var testBoard = board.copy()
           apply(move, on: &testBoard)

           let enemy = testBoard.sideToMove
           let kingSquare = testBoard.kingSquare(of: enemy)

           if AttackDetector.isSquareAttacked(
               kingSquare,
               by: enemy.opposite,
               board: testBoard
           ) {
               if isCheckmate(on: testBoard) {
                   return san + "#"
               }
               return san + "+"
           }

           return san
       }

       private static func isCheckmate(on board: Board) -> Bool {
           let color = board.sideToMove

           for from in 0..<64 {
               guard let piece = board.squares[from],
                     piece.color == color else { continue }

               for to in 0..<64 {
                   let move = Move(from: from, to: to)
                   if MoveValidator.isLegal(move: move, on: board) {
                       return false
                   }
               }
           }
           return true
       }

       private static func apply(_ move: Move, on board: inout Board) {
           board.squares[move.to] = board.squares[move.from]
           board.squares[move.from] = nil
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
