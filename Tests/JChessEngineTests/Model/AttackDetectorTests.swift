//
//  AttackDetectorTests.swift
//  JChessEngine
//
//  Created by Javid Asgarov on 14.01.26.
//
import XCTest
import JChessEngine

final class AttackDetectorTests: XCTestCase {
    
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
    
    // MARK: - Empty / Color Filtering
    func testNoPiecesReturnsFalse() {
        let board = emptyBoard()
        XCTAssertFalse(AttackDetector.isSquareAttacked(27, by: .white, board: board))
    }
    
    func testPieceOfWrongColorIsIgnored() {
        let board = boardWithPiece(at: 0, type: .rook, color: .black)
        XCTAssertFalse(AttackDetector.isSquareAttacked(8, by: .white, board: board))
    }
    
    // MARK: - Rook
    func testRookAttacksSameFile() {
        let board = boardWithPiece(at: AttackDetector.squareIndex("a1"), type: .rook, color: .white)
        
        let attackedSquares = [
            "a2", "a3", "a4", "a5", "a6", "a7", "a8",
            "b1", "c1", "d1", "e1", "f1", "g1", "h1"
        ]
        
        attackedSquares.forEach{
            XCTAssertTrue(AttackDetector.isSquareAttacked($0, by: .white, board: board))
        }
    }
    
    func testRookAttacksSameRank() {
        let board = boardWithPiece(at: 0, type: .rook, color: .white)
        XCTAssertTrue(AttackDetector.isSquareAttacked(7, by: .white, board: board))
    }
    
    func testRookDoesNotAttackDiagonal() {
        let board = boardWithPiece(at: 0, type: .rook, color: .white)
        XCTAssertFalse(AttackDetector.isSquareAttacked(9, by: .white, board: board))
    }
    
    // MARK: - Bishop
    
    func testBishopAttacksDiagonal() {
        let board = boardWithPiece(at: AttackDetector.squareIndex("d3"), type: .bishop, color: .white)
        
        let attackedSquares = [
            "c2", "b1", "e4", "f5", "g6", "h7",
            "e2", "f1", "c4", "b5", "a6"
        ]
        
        attackedSquares.forEach{
            XCTAssertTrue(AttackDetector.isSquareAttacked($0, by: .white, board: board))
        }
    }
    
    func testBishopDoesNotAttackStraightLine() {
        let board = boardWithPiece(at: AttackDetector.squareIndex("d3"), type: .bishop, color: .white)
        
        
        let excludedSquares = [
            // Rank 1
            "a1", "c1", "d1", "e1", "g1", "h1",
            // Rank 2
            "a2", "b2", "d2", "f2", "g2", "h2",
            // Rank 3
            "a3", "b3", "c3", "e3", "f3", "g3", "h3",
            // Rank 4
            "a4", "b4", "d4", "f4", "g4", "h4",
            // Rank 5
            "a5", "c5", "d5", "e5", "g5", "h5",
            // Rank 6
            "b6", "c6", "d6", "e6", "f6", "h6",
            // Rank 7
            "a7", "b7", "c7", "d7", "e7", "f7", "g7",
            // Rank 8
            "a8", "b8", "c8", "d8", "e8", "f8", "g8", "h8"
        ]
        
        excludedSquares.forEach{
            XCTAssertFalse(AttackDetector.isSquareAttacked($0, by: .white, board: board), "Failed for \($0)")
        }
    }
    
    // MARK: - Queen
    func testQueenAttacksDiagonal() {
        let board = boardWithPiece(at: AttackDetector.squareIndex("d2"), type: .queen, color: .white)
        
        let attackedSquares = [
            "a2", "b2", "c2", "e2", "f2", "g2", "h2",
            "d1", "d3", "d4", "d5", "d6", "d7", "d8",
            "c1", "e1",
            "c3", "b4", "a5",
            "e3", "f4", "g5", "h6"
        ]
        
        attackedSquares.forEach{
            XCTAssertTrue(AttackDetector.isSquareAttacked($0, by: .white, board: board))
        }
    }
    
    func testQueenDoesNotAttackSquares() {
        let board = boardWithPiece(at: AttackDetector.squareIndex("d2"), type: .queen, color: .white)
        
        let excludedSquares = [
            "a1", "a3", "a4", "a6", "a7", "a8",
            "b1", "b3", "b5", "b6", "b7", "b8",
            "c4", "c5", "c6", "c7", "c8",
            "e4", "e5", "e6", "e7", "e8",
            "f1", "f3", "f5", "f6", "f7", "f8",
            "g1", "g3", "g4", "g6", "g7", "g8",
            "h1", "h3", "h4", "h5", "h7", "h8"
        ]
        
        excludedSquares.forEach{
            XCTAssertFalse(AttackDetector.isSquareAttacked($0, by: .white, board: board), "Failed for \($0)")
        }
    }
    
    func testQueenDoesNotAttackKnightMove() {
        let board = boardWithPiece(at: AttackDetector.squareIndex("b1"), type: .queen, color: .white)
        XCTAssertFalse(AttackDetector.isSquareAttacked("a3", by: .white, board: board))
        XCTAssertFalse(AttackDetector.isSquareAttacked("c3", by: .white, board: board))
    }
    
    // MARK: - Knight
    func testKnightAttacksLShapeOne() {
        let board = boardWithPiece(at: AttackDetector.squareIndex("c3"), type: .knight, color: .white)
        
        let squaresKnightAttacks: Set<String> = [
            "b1",
            "a2",
            "d1",
            "e2",
            "b5",
            "a4",
            "d5",
            "e4"
        ]
        
        squaresKnightAttacks.forEach{
            XCTAssertTrue(AttackDetector.isSquareAttacked($0, by: .white, board: board))
        }
    }
    
    func testKnightDoesNotAttackOtherSquares() {
        let board = boardWithPiece(at: AttackDetector.squareIndex("c3"), type: .knight, color: .white)
        
        let otherSquares: [String] = [
            // Rank 1
            "a1", "c1", "f1", "g1", "h1",
            // Rank 2
            "b2", "c2", "d2", "f2", "g2", "h2",
            // Rank 3
            "a3", "b3", "c3", "d3", "e3", "f3", "g3", "h3",
            // Rank 4
            "b4", "c4", "d4", "f4", "g4", "h4",
            // Rank 5
            "a5", "c5", "e5", "f5", "g5", "h5",
            // Rank 6
            "a6", "b6", "c6", "d6", "e6", "f6", "g6", "h6",
            // Rank 7
            "a7", "b7", "c7", "d7", "e7", "f7", "g7", "h7",
            // Rank 8
            "a8", "b8", "c8", "d8", "e8", "f8", "g8", "h8"
        ]
        
        otherSquares.forEach{
            XCTAssertFalse(AttackDetector.isSquareAttacked($0, by: .white, board: board))
            
        }
    }
    
    // MARK: - King
    func testKingAttacksAdjacentSquare() {
        let board = boardWithPiece(at: AttackDetector.squareIndex("d4"), type: .king, color: .white)
        
        XCTAssertTrue(AttackDetector.isSquareAttacked("c5", by: .white, board: board))
        XCTAssertTrue(AttackDetector.isSquareAttacked("d5", by: .white, board: board))
        XCTAssertTrue(AttackDetector.isSquareAttacked("e5", by: .white, board: board))
        XCTAssertTrue(AttackDetector.isSquareAttacked("c4", by: .white, board: board))
        XCTAssertTrue(AttackDetector.isSquareAttacked("e4", by: .white, board: board))
        XCTAssertTrue(AttackDetector.isSquareAttacked("c3", by: .white, board: board))
        XCTAssertTrue(AttackDetector.isSquareAttacked("d3", by: .white, board: board))
        XCTAssertTrue(AttackDetector.isSquareAttacked("e3", by: .white, board: board))
        
        
        XCTAssertFalse(AttackDetector.isSquareAttacked("c6", by: .white, board: board))
        XCTAssertFalse(AttackDetector.isSquareAttacked("d6", by: .white, board: board))
        XCTAssertFalse(AttackDetector.isSquareAttacked("e6", by: .white, board: board))
        XCTAssertFalse(AttackDetector.isSquareAttacked("b4", by: .white, board: board))
        XCTAssertFalse(AttackDetector.isSquareAttacked("f4", by: .white, board: board))
        XCTAssertFalse(AttackDetector.isSquareAttacked("c2", by: .white, board: board))
        XCTAssertFalse(AttackDetector.isSquareAttacked("d2", by: .white, board: board))
        XCTAssertFalse(AttackDetector.isSquareAttacked("e2", by: .white, board: board))
    }
    
    func testKingDoesNotAttackDistantSquare() {
        let board = boardWithPiece(at: AttackDetector.squareIndex("d4"), type: .king, color: .white)
        XCTAssertFalse(AttackDetector.isSquareAttacked("a1", by: .white, board: board))
        XCTAssertFalse(AttackDetector.isSquareAttacked("a8", by: .white, board: board))
        XCTAssertFalse(AttackDetector.isSquareAttacked("h1", by: .white, board: board))
        XCTAssertFalse(AttackDetector.isSquareAttacked("h8", by: .white, board: board))
    }
    
    // MARK: - Pawn (White)
    func testWhitePawnAttacksUpLeft() {
        let board = boardWithPiece(at: AttackDetector.squareIndex("b2"), type: .pawn, color: .white)
        
        XCTAssertTrue(AttackDetector.isSquareAttacked("a3", by: .white, board: board))
        XCTAssertTrue(AttackDetector.isSquareAttacked("c3", by: .white, board: board))
    }
    
    func testWhitePawnDoesNotAnywhereIllegal() {
        let board = boardWithPiece(at: AttackDetector.squareIndex("b2"), type: .pawn, color: .white)
        
        XCTAssertFalse(AttackDetector.isSquareAttacked("b3", by: .white, board: board))
        XCTAssertFalse(AttackDetector.isSquareAttacked("a2", by: .white, board: board))
        XCTAssertFalse(AttackDetector.isSquareAttacked("c2", by: .white, board: board))
        XCTAssertFalse(AttackDetector.isSquareAttacked("a1", by: .white, board: board))
        XCTAssertFalse(AttackDetector.isSquareAttacked("b1", by: .white, board: board))
        XCTAssertFalse(AttackDetector.isSquareAttacked("c1", by: .white, board: board))
    }
    
    // MARK: - Pawn (Black)
    func testBlackPawnAttacksDownRight() {
        let board = boardWithPiece(at: 17, type: .pawn, color: .black)
        XCTAssertTrue(AttackDetector.isSquareAttacked(8, by: .black, board: board))
    }
    
    func testBlackPawnDoesNotAttackBackward() {
        let board = boardWithPiece(at: 17, type: .pawn, color: .black)
        XCTAssertFalse(AttackDetector.isSquareAttacked(26, by: .black, board: board))
    }
    
    
    // MARK: - Check that does not attack when piece is blocking
    func testRookAttacksSameFileButNotWhenBlocked() {
        var board = boardWithPiece(at: AttackDetector.squareIndex("a1"), type: .rook, color: .white)
        board.squares[AttackDetector.squareIndex("a5")] = Piece(type: .pawn, color: .black)
        board.squares[AttackDetector.squareIndex("f1")] = Piece(type: .pawn, color: .black)
        
        let attackedSquares = [
            "a2", "a3", "a4", "a5",
            "b1", "c1", "d1", "e1", "f1"
        ]
        
        attackedSquares.forEach{
            XCTAssertTrue(AttackDetector.isSquareAttacked($0, by: .white, board: board))
        }
        
        let blockedSquares = [
            "a6", "a7", "a8", "g1", "h1"
        ]
        
        blockedSquares.forEach{
            XCTAssertFalse(AttackDetector.isSquareAttacked($0, by: .white, board: board), "Failed for \($0)")
        }
    }
    
    func testBishopAttacksDiagonalsButNotWhenBlocked() {
        var board = boardWithPiece(
            at: AttackDetector.squareIndex("c1"),
            type: .bishop,
            color: .white
        )
        
        // Blockers
        board.squares[AttackDetector.squareIndex("f4")] = Piece(type: .pawn, color: .black)
        board.squares[AttackDetector.squareIndex("a3")] = Piece(type: .pawn, color: .black)

        let attackedSquares = [
            // Up-right diagonal until blocked
            "d2", "e3", "f4",
            // Up-left diagonal until blocked
            "b2", "a3"
        ]

        attackedSquares.forEach {
            XCTAssertTrue(
                AttackDetector.isSquareAttacked($0, by: .white, board: board),
                "Expected \($0) to be attacked"
            )
        }

        let blockedSquares = [
            // Beyond blockers
            "g5", "h6",
            "b4", "a5"
        ]

        blockedSquares.forEach {
            XCTAssertFalse(
                AttackDetector.isSquareAttacked($0, by: .white, board: board),
                "Expected \($0) to NOT be attacked"
            )
        }
    }
    
    func testQueenAttacksRanksFilesAndDiagonalsButNotWhenBlocked() {
        var board = boardWithPiece(
            at: AttackDetector.squareIndex("d4"),
            type: .queen,
            color: .white
        )
        
        // Blockers
        board.squares[AttackDetector.squareIndex("d6")] = Piece(type: .pawn, color: .black)
        board.squares[AttackDetector.squareIndex("f4")] = Piece(type: .pawn, color: .black)
        board.squares[AttackDetector.squareIndex("b2")] = Piece(type: .pawn, color: .black)

        let attackedSquares = [
            // File
            "d5", "d6",
            // Rank
            "e4", "f4",
            "c4", "b4", "a4",
            // Diagonals
            "e5", "f6", "g7", "h8",
            "c3", "b2"
        ]

        attackedSquares.forEach {
            XCTAssertTrue(
                AttackDetector.isSquareAttacked($0, by: .white, board: board),
                "Expected \($0) to be attacked"
            )
        }

        let blockedSquares = [
            // Beyond blockers
            "d7", "d8",
            "g4", "h4",
            "a1"
        ]

        blockedSquares.forEach {
            XCTAssertFalse(
                AttackDetector.isSquareAttacked($0, by: .white, board: board),
                "Expected \($0) to NOT be attacked"
            )
        }
    }
    
    func testKnightAttacksAllEightSquaresEvenWhenBlocked() {
        var board = boardWithPiece(
            at: AttackDetector.squareIndex("d4"),
            type: .knight,
            color: .white
        )
        
        // Place blocking pieces around the knight (should NOT matter)
        let blockingSquares = [
            "d5", "e5", "e4", "e3",
            "d3", "c3", "c4", "c5"
        ]
        
        blockingSquares.forEach {
            board.squares[AttackDetector.squareIndex($0)] =
                Piece(type: .pawn, color: .black)
        }

        let attackedSquares = [
            "b3", "b5",
            "c2", "c6",
            "e2", "e6",
            "f3", "f5"
        ]

        attackedSquares.forEach {
            XCTAssertTrue(
                AttackDetector.isSquareAttacked($0, by: .white, board: board),
                "Expected knight to attack \($0) despite blockers"
            )
        }
    }


}
