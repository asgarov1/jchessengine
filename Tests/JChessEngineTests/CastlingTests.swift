
import XCTest
import JChessEngine

final class CastlingTests: XCTestCase {

    func testCastlingBlockedByPiece() {
        let game = Game(fen: "r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")
        XCTAssertFalse(try game.make(from: 4, to: 6, type: .castleKingSide))
    }

    func testCastlingThroughCheck() {
        let game = Game(fen: "r3k2r/8/8/8/8/5r2/8/R3K2R w KQkq - 0 1")
        XCTAssertFalse(try game.make(from: 4, to: 6, type: .castleKingSide))
    }

    func testCastlingAfterKingMoved() throws {
        let game = Game()
        _ = try game.make(from: 4, to: 5)
        _ = try game.make(from: 60, to: 61)
        XCTAssertFalse(try game.make(from: 5, to: 7, type: .castleKingSide))
    }

    func testValidQueenSideCastling() {
        let game = Game(fen: "r3k2r/8/8/8/8/8/8/R3K2R w Q - 0 1")
        XCTAssertTrue(try game.make(from: 4, to: 2, type: .castleQueenSide))
    }
}
