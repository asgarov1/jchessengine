//
//  MoveTests.swift
//  JChessEngine
//
//  Created by Javid Asgarov on 15.01.26.
//
import XCTest
import JChessEngine

final class GameTests: XCTestCase {
    
    // MARK: - Ongoing
    
    func testGameResultOngoingFromStartingPosition() {
        let game = Game(
            fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        )
        
        let result = game.gameResult()
        
        XCTAssertEqual(result, .ongoing)
    }
    
    // MARK: - Checkmate
    
    /// Fool's mate:
    /// 1. f3 e5
    /// 2. g4 Qh4#
    ///
    /// Black has just delivered mate, White to move.
    func testGameResultCheckmate() {
        let game = Game(
            fen: "rnb1kbnr/pppp1ppp/8/4p3/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 1 3"
        )
        
        let result = game.gameResult()
        
        XCTAssertEqual(result, .checkmate(winner: .black))
    }
    
    // MARK: - Stalemate
    
    /// Classic stalemate:
    /// Black to move, no legal moves, not in check
    ///
    /// White: King c6, Queen b6
    /// Black: King a8
    func testGameResultStalemate() {
        let game = Game(
            fen: "k7/8/1QK5/8/8/8/8/8 b - - 0 1"
        )
        
        let result = game.gameResult()
        
        XCTAssertEqual(result, .stalemate)
    }
    
    func testMoveHistoryStartsEmpty() {
        let game = Game()
        XCTAssertTrue(game.board.moveHistory.isEmpty, "Move history should start empty")
    }
    
    func testValidMoveIsAddedToHistory() throws {
        let game = Game()
        
        let success = try game.make(from: "e2", to: "e4")
        
        XCTAssertTrue(success, "Move should be legal")
        XCTAssertEqual(game.board.moveHistory.count, 1, "Exactly one move should be recorded")
        
        let recordedMove = game.board.moveHistory.first
        XCTAssertEqual(recordedMove?.from, MoveUtil.squareIndex("e2"))
        XCTAssertEqual(recordedMove?.to, MoveUtil.squareIndex("e4"))
    }
    
    func testInvalidMoveIsNotAddedToHistory() throws {
        let game = Game()
        
        XCTAssertThrowsError(try game.make(from: "e2", to: "e1"))
        
        XCTAssertTrue(game.board.moveHistory.isEmpty, "Illegal move must not be recorded")
    }
    
    func testMultipleValidMovesAreRecordedInOrder() throws {
        let game = Game()
        
        XCTAssertTrue(try game.make(from: "e2", to: "e4"))
        XCTAssertTrue(try game.make(from: "e7", to: "e5"))
        XCTAssertTrue(try game.make(from: "g1", to: "f3"))
        
        XCTAssertEqual(game.board.moveHistory.count, 3)
        
        XCTAssertEqual(game.board.moveHistory[0].san, "e4")
        XCTAssertEqual(game.board.moveHistory[1].san, "e5")
        XCTAssertEqual(game.board.moveHistory[2].san, "Nf3")
    }
    
    func testInvalidMoveDoesNotBreakHistorySequence() throws {
        let game = Game()
        
        XCTAssertTrue(try game.make(from: "e2", to: "e4"))
        XCTAssertThrowsError(try game.make(move: "d3")) // illegal pawn move for black
        XCTAssertTrue(try game.make(from: "d7", to: "d5"))
        
        XCTAssertEqual(game.board.moveHistory.count, 2)
        XCTAssertEqual(game.board.moveHistory[0].fromText(), "e2")
        XCTAssertEqual(game.board.moveHistory[0].toText(), "e4")
        
        XCTAssertEqual(game.board.moveHistory[1].fromText(), "d7")
        XCTAssertEqual(game.board.moveHistory[1].toText(), "d5")
    }
    
    // MARK: PGN Tests
    func testPGNWithNoMovesIsEmpty() {
        let game = Game()
        
        let pgn = game.pgn()
        
        XCTAssertEqual(pgn, "")
    }
    
    func testPGNWithOneMove() throws {
        let game = Game()
        
        let move = try MoveResolver.resolve(san: "e4", board: game.board)
        XCTAssertTrue(game.make(move: move))
        
        let pgn = game.pgn()
        XCTAssertEqual(pgn, "1. e4")
    }
    
    func testPGNWithTwoMoves() throws {
        let game = Game()
        
        let moveOne = try MoveResolver.resolve(san: "e4", board: game.board)
        XCTAssertTrue(game.make(move: moveOne))
        
        let moveTwo = try MoveResolver.resolve(san: "e5", board: game.board)
        XCTAssertTrue(game.make(move: moveTwo))
        
        let pgn = game.pgn()
        XCTAssertEqual(pgn, "1. e4 e5")
    }
    
    func testPGNWithThreeMoves() throws {
        let game = Game()
        
        let moveOne = try MoveResolver.resolve(san: "e4", board: game.board)
        XCTAssertTrue(game.make(move: moveOne))
        
        let moveTwo = try MoveResolver.resolve(san: "e5", board: game.board)
        XCTAssertTrue(game.make(move: moveTwo))
        
        let moveThree = try MoveResolver.resolve(san: "Nf3", board: game.board)
        XCTAssertTrue(game.make(move: moveThree))
        
        let pgn = game.pgn()
        XCTAssertEqual(pgn, "1. e4 e5 2. Nf3")
    }
    
    func testPGNWithFourMoves() throws {
        let game = Game()
        
        let moveOne = try MoveResolver.resolve(san: "e4", board: game.board)
        XCTAssertTrue(game.make(move: moveOne))
        
        let moveTwo = try MoveResolver.resolve(san: "e5", board: game.board)
        XCTAssertTrue(game.make(move: moveTwo))
        
        let moveThree = try MoveResolver.resolve(san: "Nf3", board: game.board)
        XCTAssertTrue(game.make(move: moveThree))
        
        let moveFour = try MoveResolver.resolve(san: "Nc6", board: game.board)
        XCTAssertTrue(game.make(move: moveFour))
        
        let pgn = game.pgn()
        XCTAssertEqual(pgn, "1. e4 e5 2. Nf3 Nc6")
    }
    
    func testPGNWithCastling() throws {
        let game = Game()
        
        XCTAssertTrue(try game.make(move: "e4"))
        XCTAssertTrue(try game.make(move: "e5"))
        XCTAssertTrue(try game.make(move: "Nf3"))
        XCTAssertTrue(try game.make(move: "Nf6"))
        XCTAssertTrue(try game.make(move: "Bc4"))
        XCTAssertTrue(try game.make(move: "Bc5"))
        XCTAssertTrue(try game.make(move: "O-O"))
        
        let pgn = game.pgn()
        XCTAssertEqual(pgn, "1. e4 e5 2. Nf3 Nf6 3. Bc4 Bc5 4. O-O")
    }
}
