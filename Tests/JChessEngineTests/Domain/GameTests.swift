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
    }}
