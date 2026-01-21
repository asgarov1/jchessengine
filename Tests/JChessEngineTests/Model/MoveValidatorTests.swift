//
//  AttackDetectorTests.swift
//  JChessEngine
//
//  Created by Javid Asgarov on 14.01.26.
//
import XCTest
import JChessEngine

final class MoveValidatorTests: XCTestCase {
    
    // MARK: - Helpers
    
    private func emptyBoard() -> Board {
        Board()
    }
    
    private func boardWithPiece(
        at index: Int,
        type: PieceType,
        color: Color
    ) -> Board {
        var board = Board()
        board.squares = Array(repeating: nil as Piece?, count: 64)
        board.squares[index] = Piece(type: type, color: color)
        return board
    }
    
    private func boardWithPiece(
        at coordinate: String,
        type: PieceType,
        color: Color
    ) -> Board {
        return boardWithPiece(at: CoordinateUtil.squareIndex(coordinate), type: type, color: color)
    }
    
    // MARK: - Empty / Color Filtering
    func testNoPiecesReturnsFalse() {
        let board = emptyBoard()
        XCTAssertFalse(MoveValidator.isLegal(from: "d2", to: "d4", on: board))
    }
    
    func testPieceOfWrongColorReturnsFalse() {
        let board = boardWithPiece(at: "d7", type: .pawn, color: .black)
        XCTAssertFalse(MoveValidator.isLegal(from: "d7", to: "d5", on: board))
    }
    
    func testPieceOfCorrectColorReturnsTrue() {
        let board = boardWithPiece(at: "d2", type: .pawn, color: .white)
        XCTAssertTrue(MoveValidator.isLegal(from: "d2", to: "d4", on: board))
    }
    
    // MARK: - Rook
    func testRookCanMoveOnItsFile() {
        let board = boardWithPiece(at: "a1", type: .rook, color: .white)
        
        let attackedSquares = [
            "a2", "a3", "a4", "a5", "a6", "a7", "a8",
            "b1", "c1", "d1", "e1", "f1", "g1", "h1"
        ]
        
        attackedSquares.forEach {
            XCTAssertTrue(MoveValidator.isLegal(from: "a1", to: $0, on: board))
        }
    }
    
    func testRookCanNotMoveToSquareIfSquareIsBlockedByItsPiece() {
        var board = boardWithPiece(at: "a1", type: .rook, color: .white)
        board.squares[CoordinateUtil.squareIndex("a6")] = Piece(type: .pawn, color: .white)
        board.squares[CoordinateUtil.squareIndex("f1")] = Piece(type: .pawn, color: .white)
        
        let attackedSquares = [
            "a2", "a3", "a4", "a5",
            "b1", "c1", "d1", "e1"
        ]
        
        attackedSquares.forEach {
            XCTAssertTrue(MoveValidator.isLegal(from: "a1", to: $0, on: board))
        }
        
        let blockedSquares = [
            "a6", "a7", "a8",
            "f1", "g1", "h1"
        ]
        blockedSquares.forEach {
            XCTAssertFalse(MoveValidator.isLegal(from: "a1", to: $0, on: board))
        }
    }
    
    func testWhiteRookCanMoveToSquareIfSquareIsBlockedByPieceItCanCapture() {
        // white rook blocked by black pawns
        var board = boardWithPiece(at: "a1", type: .rook, color: .white)
        board.squares[CoordinateUtil.squareIndex("a6")] = Piece(type: .pawn, color: .black)
        board.squares[CoordinateUtil.squareIndex("f1")] = Piece(type: .pawn, color: .black)

        // white rook can capture black pawns
        XCTAssertTrue(MoveValidator.isLegal(from: "a1", to: "a6", on: board))
        XCTAssertTrue(MoveValidator.isLegal(from: "a1", to: "f1", on: board))
    }
    
    func testBlackRookCanMoveToSquareIfSquareIsBlockedByPieceItCanCapture() {
        // black rook blocked by white pawns
        var board = boardWithPiece(at: "b2", type: .rook, color: .black)
        board.squares[CoordinateUtil.squareIndex("b6")] = Piece(type: .pawn, color: .white)
        board.squares[CoordinateUtil.squareIndex("f2")] = Piece(type: .pawn, color: .white)

        // AND its black's turn
        board.sideToMove = .black
        
        // black can capture white pawns
        XCTAssertTrue(MoveValidator.isLegal(from: "b2", to: "b6", on: board))
        XCTAssertTrue(MoveValidator.isLegal(from: "b2", to: "f2", on: board))
    }
    
    
    // MARK: - Knight
    
//    func testIfWhiteKingUnderCheckRookCanNotMoveExceptToBlockTheCheck() {
//        // black rook blocked by white pawns
//        var board = boardWithPiece(at: "b2", type: .rook, color: .black)
//        board.squares[CoordinateUtil.squareIndex("f1")] = Piece(type: .king, color: .black)
//        
//        // rook attacking king
//        board.squares[CoordinateUtil.squareIndex("f8")] = Piece(type: .rook, color: .white)
//        
//        // its blacks turn
//        board.sideToMove = .black
//        
//        // rook can't make arbitrary move that doesn't block check
//        XCTAssertFalse(MoveValidator.isLegal(move: Move(from: "b2", to: "b6"), on: board))
//        
//        // rook can block the check
//        XCTAssertTrue(MoveValidator.isLegal(move: Move(from: "b2", to: "f2"), on: board))
//    }
//    
//    func testIfWhiteKingUnderCheckRookCanNotMoveExceptToCaptureTheChecker() {
//        // black rook blocked by white pawns
//        var board = boardWithPiece(at: "b8", type: .rook, color: .black)
//        board.squares[CoordinateUtil.squareIndex("f1")] = Piece(type: .king, color: .black)
//        
//        // rook attacking king
//        board.squares[CoordinateUtil.squareIndex("f8")] = Piece(type: .rook, color: .white)
//        
//        // its blacks turn
//        board.sideToMove = .black
//        
//        // rook can't make arbitrary move that doesn't block/capture check
//        XCTAssertFalse(MoveValidator.isLegal(move: Move(from: "b8", to: "b6"), on: board))
//        
//        // rook can capture the checker
//        XCTAssertTrue(MoveValidator.isLegal(move: Move(from: "b8", to: "f8"), on: board))
//    }
    
    // MARK: - Bishop
    
//    func testBishopAttacksDiagonal() {
//        let board = boardWithPiece(at: CoordinateUtil.squareIndex("d3"), type: .bishop, color: .white)
//
//        let attackedSquares = [
//            "c2", "b1", "e4", "f5", "g6", "h7",
//            "e2", "f1", "c4", "b5", "a6"
//        ]
//
//        attackedSquares.forEach{
//            XCTAssertTrue(AttackDetector.isSquareAttacked($0, by: .white, board: board))
//        }
//    }
//
//    func testBishopDoesNotAttackStraightLine() {
//        let board = boardWithPiece(at: CoordinateUtil.squareIndex("d3"), type: .bishop, color: .white)
//
//
//        let excludedSquares = [
//            // Rank 1
//            "a1", "c1", "d1", "e1", "g1", "h1",
//            // Rank 2
//            "a2", "b2", "d2", "f2", "g2", "h2",
//            // Rank 3
//            "a3", "b3", "c3", "e3", "f3", "g3", "h3",
//            // Rank 4
//            "a4", "b4", "d4", "f4", "g4", "h4",
//            // Rank 5
//            "a5", "c5", "d5", "e5", "g5", "h5",
//            // Rank 6
//            "b6", "c6", "d6", "e6", "f6", "h6",
//            // Rank 7
//            "a7", "b7", "c7", "d7", "e7", "f7", "g7",
//            // Rank 8
//            "a8", "b8", "c8", "d8", "e8", "f8", "g8", "h8"
//        ]
//
//        excludedSquares.forEach{
//            XCTAssertFalse(AttackDetector.isSquareAttacked($0, by: .white, board: board), "Failed for \($0)")
//        }
//    }
//
//    // MARK: - Queen
//    func testQueenAttacksDiagonal() {
//        let board = boardWithPiece(at: CoordinateUtil.squareIndex("d2"), type: .queen, color: .white)
//
//        let attackedSquares = [
//            "a2", "b2", "c2", "e2", "f2", "g2", "h2",
//            "d1", "d3", "d4", "d5", "d6", "d7", "d8",
//            "c1", "e1",
//            "c3", "b4", "a5",
//            "e3", "f4", "g5", "h6"
//        ]
//
//        attackedSquares.forEach{
//            XCTAssertTrue(AttackDetector.isSquareAttacked($0, by: .white, board: board))
//        }
//    }
//
//    func testQueenDoesNotAttackSquares() {
//        let board = boardWithPiece(at: CoordinateUtil.squareIndex("d2"), type: .queen, color: .white)
//
//        let excludedSquares = [
//            "a1", "a3", "a4", "a6", "a7", "a8",
//            "b1", "b3", "b5", "b6", "b7", "b8",
//            "c4", "c5", "c6", "c7", "c8",
//            "e4", "e5", "e6", "e7", "e8",
//            "f1", "f3", "f5", "f6", "f7", "f8",
//            "g1", "g3", "g4", "g6", "g7", "g8",
//            "h1", "h3", "h4", "h5", "h7", "h8"
//        ]
//
//        excludedSquares.forEach{
//            XCTAssertFalse(AttackDetector.isSquareAttacked($0, by: .white, board: board), "Failed for \($0)")
//        }
//    }
//
//    func testQueenDoesNotAttackKnightMove() {
//        let board = boardWithPiece(at: CoordinateUtil.squareIndex("b1"), type: .queen, color: .white)
//        XCTAssertFalse(AttackDetector.isSquareAttacked("a3", by: .white, board: board))
//        XCTAssertFalse(AttackDetector.isSquareAttacked("c3", by: .white, board: board))
//    }
//
//    // MARK: - Knight
//    func testKnightAttacksLShapeOne() {
//        let board = boardWithPiece(at: CoordinateUtil.squareIndex("c3"), type: .knight, color: .white)
//
//        let squaresKnightAttacks: Set<String> = [
//            "b1",
//            "a2",
//            "d1",
//            "e2",
//            "b5",
//            "a4",
//            "d5",
//            "e4"
//        ]
//
//        squaresKnightAttacks.forEach{
//            XCTAssertTrue(AttackDetector.isSquareAttacked($0, by: .white, board: board))
//        }
//    }
//
//    func testKnightDoesNotAttackOtherSquares() {
//        let board = boardWithPiece(at: CoordinateUtil.squareIndex("c3"), type: .knight, color: .white)
//
//        let otherSquares: [String] = [
//            // Rank 1
//            "a1", "c1", "f1", "g1", "h1",
//            // Rank 2
//            "b2", "c2", "d2", "f2", "g2", "h2",
//            // Rank 3
//            "a3", "b3", "c3", "d3", "e3", "f3", "g3", "h3",
//            // Rank 4
//            "b4", "c4", "d4", "f4", "g4", "h4",
//            // Rank 5
//            "a5", "c5", "e5", "f5", "g5", "h5",
//            // Rank 6
//            "a6", "b6", "c6", "d6", "e6", "f6", "g6", "h6",
//            // Rank 7
//            "a7", "b7", "c7", "d7", "e7", "f7", "g7", "h7",
//            // Rank 8
//            "a8", "b8", "c8", "d8", "e8", "f8", "g8", "h8"
//        ]
//
//        otherSquares.forEach{
//            XCTAssertFalse(AttackDetector.isSquareAttacked($0, by: .white, board: board))
//
//        }
//    }
//
//    // MARK: - King
//    func testKingAttacksAdjacentSquare() {
//        let board = boardWithPiece(at: CoordinateUtil.squareIndex("d4"), type: .king, color: .white)
//
//        XCTAssertTrue(AttackDetector.isSquareAttacked("c5", by: .white, board: board))
//        XCTAssertTrue(AttackDetector.isSquareAttacked("d5", by: .white, board: board))
//        XCTAssertTrue(AttackDetector.isSquareAttacked("e5", by: .white, board: board))
//        XCTAssertTrue(AttackDetector.isSquareAttacked("c4", by: .white, board: board))
//        XCTAssertTrue(AttackDetector.isSquareAttacked("e4", by: .white, board: board))
//        XCTAssertTrue(AttackDetector.isSquareAttacked("c3", by: .white, board: board))
//        XCTAssertTrue(AttackDetector.isSquareAttacked("d3", by: .white, board: board))
//        XCTAssertTrue(AttackDetector.isSquareAttacked("e3", by: .white, board: board))
//
//
//        XCTAssertFalse(AttackDetector.isSquareAttacked("c6", by: .white, board: board))
//        XCTAssertFalse(AttackDetector.isSquareAttacked("d6", by: .white, board: board))
//        XCTAssertFalse(AttackDetector.isSquareAttacked("e6", by: .white, board: board))
//        XCTAssertFalse(AttackDetector.isSquareAttacked("b4", by: .white, board: board))
//        XCTAssertFalse(AttackDetector.isSquareAttacked("f4", by: .white, board: board))
//        XCTAssertFalse(AttackDetector.isSquareAttacked("c2", by: .white, board: board))
//        XCTAssertFalse(AttackDetector.isSquareAttacked("d2", by: .white, board: board))
//        XCTAssertFalse(AttackDetector.isSquareAttacked("e2", by: .white, board: board))
//    }
//
//    func testKingDoesNotAttackDistantSquare() {
//        let board = boardWithPiece(at: CoordinateUtil.squareIndex("d4"), type: .king, color: .white)
//        XCTAssertFalse(AttackDetector.isSquareAttacked("a1", by: .white, board: board))
//        XCTAssertFalse(AttackDetector.isSquareAttacked("a8", by: .white, board: board))
//        XCTAssertFalse(AttackDetector.isSquareAttacked("h1", by: .white, board: board))
//        XCTAssertFalse(AttackDetector.isSquareAttacked("h8", by: .white, board: board))
//    }
//
    // MARK: - Pawn (White)
    func testPawnCanBothSingleAndDoublePushFromStartingPosition() {
        let board = boardWithPiece(at: CoordinateUtil.squareIndex("b2"), type: .pawn, color: .white)

        XCTAssertTrue(MoveValidator.isLegal(from: "b2", to: "b3", on: board))
        XCTAssertTrue(MoveValidator.isLegal(from: "b2", to: "b4", on: board))
    }
    
    func testPawnCanOnlySinglePushFromNotStartingPosition() {
        let board = boardWithPiece(at: CoordinateUtil.squareIndex("b3"), type: .pawn, color: .white)

        XCTAssertTrue(MoveValidator.isLegal(from: "b3", to: "b4", on: board))
        XCTAssertFalse(MoveValidator.isLegal(from: "b3", to: "b5", on: board))
    }
    
    func testPawnCanMoveDiagonalSingleStepIfThereIsAPieceToCapture() {
        var board = boardWithPiece(at: CoordinateUtil.squareIndex("b2"), type: .pawn, color: .white)
        board.set(piece: Piece(type: .pawn, color: .black), at: "a3")
        board.set(piece: Piece(type: .pawn, color: .black), at: "c3")

        XCTAssertTrue(MoveValidator.isLegal(from: "b2", to: "a3", on: board))
        XCTAssertTrue(MoveValidator.isLegal(from: "b2", to: "c3", on: board))
        
        // but can't keep traveling diagonally
        XCTAssertFalse(MoveValidator.isLegal(from: "b2", to: "d4", on: board))
    }
    
    func testPawnCanNotMoveDiagonalIfThereIsNoPieceToCapture() {
        let board = boardWithPiece(at: CoordinateUtil.squareIndex("b2"), type: .pawn, color: .white)

        XCTAssertFalse(MoveValidator.isLegal(from: "b2", to: "a3", on: board))
        XCTAssertFalse(MoveValidator.isLegal(from: "b2", to: "c3", on: board))
    }
//
//    func testWhitePawnDoesNotAnywhereIllegal() {
//        let board = boardWithPiece(at: CoordinateUtil.squareIndex("b2"), type: .pawn, color: .white)
//
//        XCTAssertFalse(AttackDetector.isSquareAttacked("b3", by: .white, board: board))
//        XCTAssertFalse(AttackDetector.isSquareAttacked("a2", by: .white, board: board))
//        XCTAssertFalse(AttackDetector.isSquareAttacked("c2", by: .white, board: board))
//        XCTAssertFalse(AttackDetector.isSquareAttacked("a1", by: .white, board: board))
//        XCTAssertFalse(AttackDetector.isSquareAttacked("b1", by: .white, board: board))
//        XCTAssertFalse(AttackDetector.isSquareAttacked("c1", by: .white, board: board))
//    }
//
//    // MARK: - Pawn (Black)
//    func testBlackPawnAttacksDownRight() {
//        let board = boardWithPiece(at: 17, type: .pawn, color: .black)
//        XCTAssertTrue(AttackDetector.isSquareAttacked(8, by: .black, board: board))
//    }
//
//    func testBlackPawnDoesNotAttackBackward() {
//        let board = boardWithPiece(at: 17, type: .pawn, color: .black)
//        XCTAssertFalse(AttackDetector.isSquareAttacked(26, by: .black, board: board))
//    }
//
//
//    // MARK: - Check that does not attack when piece is blocking
//    func testRookAttacksSameFileButNotWhenBlocked() {
//        var board = boardWithPiece(at: CoordinateUtil.squareIndex("a1"), type: .rook, color: .white)
//        board.squares[CoordinateUtil.squareIndex("a5")] = Piece(type: .pawn, color: .black)
//        board.squares[CoordinateUtil.squareIndex("f1")] = Piece(type: .pawn, color: .black)
//
//        let attackedSquares = [
//            "a2", "a3", "a4", "a5",
//            "b1", "c1", "d1", "e1", "f1"
//        ]
//
//        attackedSquares.forEach{
//            XCTAssertTrue(AttackDetector.isSquareAttacked($0, by: .white, board: board))
//        }
//
//        let blockedSquares = [
//            "a6", "a7", "a8", "g1", "h1"
//        ]
//
//        blockedSquares.forEach{
//            XCTAssertFalse(AttackDetector.isSquareAttacked($0, by: .white, board: board), "Failed for \($0)")
//        }
//    }
//
//    func testBishopAttacksDiagonalsButNotWhenBlocked() {
//        var board = boardWithPiece(
//            at: CoordinateUtil.squareIndex("c1"),
//            type: .bishop,
//            color: .white
//        )
//
//        // Blockers
//        board.squares[CoordinateUtil.squareIndex("f4")] = Piece(type: .pawn, color: .black)
//        board.squares[CoordinateUtil.squareIndex("a3")] = Piece(type: .pawn, color: .black)
//
//        let attackedSquares = [
//            // Up-right diagonal until blocked
//            "d2", "e3", "f4",
//            // Up-left diagonal until blocked
//            "b2", "a3"
//        ]
//
//        attackedSquares.forEach {
//            XCTAssertTrue(
//                AttackDetector.isSquareAttacked($0, by: .white, board: board),
//                "Expected \($0) to be attacked"
//            )
//        }
//
//        let blockedSquares = [
//            // Beyond blockers
//            "g5", "h6",
//            "b4", "a5"
//        ]
//
//        blockedSquares.forEach {
//            XCTAssertFalse(
//                AttackDetector.isSquareAttacked($0, by: .white, board: board),
//                "Expected \($0) to NOT be attacked"
//            )
//        }
//    }
//
//    func testQueenAttacksRanksFilesAndDiagonalsButNotWhenBlocked() {
//        var board = boardWithPiece(
//            at: CoordinateUtil.squareIndex("d4"),
//            type: .queen,
//            color: .white
//        )
//
//        // Blockers
//        board.squares[CoordinateUtil.squareIndex("d6")] = Piece(type: .pawn, color: .black)
//        board.squares[CoordinateUtil.squareIndex("f4")] = Piece(type: .pawn, color: .black)
//        board.squares[CoordinateUtil.squareIndex("b2")] = Piece(type: .pawn, color: .black)
//
//        let attackedSquares = [
//            // File
//            "d5", "d6",
//            // Rank
//            "e4", "f4",
//            "c4", "b4", "a4",
//            // Diagonals
//            "e5", "f6", "g7", "h8",
//            "c3", "b2"
//        ]
//
//        attackedSquares.forEach {
//            XCTAssertTrue(
//                AttackDetector.isSquareAttacked($0, by: .white, board: board),
//                "Expected \($0) to be attacked"
//            )
//        }
//
//        let blockedSquares = [
//            // Beyond blockers
//            "d7", "d8",
//            "g4", "h4",
//            "a1"
//        ]
//
//        blockedSquares.forEach {
//            XCTAssertFalse(
//                AttackDetector.isSquareAttacked($0, by: .white, board: board),
//                "Expected \($0) to NOT be attacked"
//            )
//        }
//    }
//
//    func testKnightAttacksAllEightSquaresEvenWhenBlocked() {
//        var board = boardWithPiece(
//            at: CoordinateUtil.squareIndex("d4"),
//            type: .knight,
//            color: .white
//        )
//
//        // Place blocking pieces around the knight (should NOT matter)
//        let blockingSquares = [
//            "d5", "e5", "e4", "e3",
//            "d3", "c3", "c4", "c5"
//        ]
//
//        blockingSquares.forEach {
//            board.squares[CoordinateUtil.squareIndex($0)] =
//            Piece(type: .pawn, color: .black)
//        }
//
//        let attackedSquares = [
//            "b3", "b5",
//            "c2", "c6",
//            "e2", "e6",
//            "f3", "f5"
//        ]
//
//        attackedSquares.forEach {
//            XCTAssertTrue(
//                AttackDetector.isSquareAttacked($0, by: .white, board: board),
//                "Expected knight to attack \($0) despite blockers"
//            )
//        }
//    }


}
