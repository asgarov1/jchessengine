
import XCTest
import JChessEngine

final class CastlingTests: XCTestCase {

    func testCastlingBlockedByPiece() {
        let game = Game(fen: "r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")
        XCTAssertFalse(game.make(move: Move(from: 4, to: 6, type: .castleKingSide)))
    }

    func testCastlingThroughCheck() {
        let game = Game(fen: "r3k2r/8/8/8/8/5r2/8/R3K2R w KQkq - 0 1")
        XCTAssertFalse(game.make(move: Move(from: 4, to: 6, type: .castleKingSide)))
    }

    func testCastlingAfterKingMoved() {
        let game = Game()
        _ = game.make(move: Move(from: 4, to: 5))
        _ = game.make(move: Move(from: 60, to: 61))
        XCTAssertFalse(game.make(move: Move(from: 5, to: 7, type: .castleKingSide)))
    }

    func testValidQueenSideCastling() {
        let game = Game(fen: "r3k2r/8/8/8/8/8/8/R3K2R w Q - 0 1")
        XCTAssertTrue(game.make(move: Move(from: 4, to: 2, type: .castleQueenSide)))
    }
}
