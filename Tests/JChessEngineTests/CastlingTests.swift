
import XCTest
import JChessEngine

final class CastlingTests: XCTestCase {

    func testCastlingBlockedByPiece() {
        let game = Game(fen: "r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")
        XCTAssertThrowsError(try game.make(from: 4, to: 6, type: .castleKingSide))
    }

    func testCastlingThroughCheck() {
        let game = Game(fen: "r3k2r/8/8/8/8/5r2/8/R3K2R w KQkq - 0 1")
        XCTAssertThrowsError(try game.make(from: 4, to: 6, type: .castleKingSide))
    }

    func testCastlingAfterKingMoved() throws {
        let game = Game(fen: "r2qk2r/pppppppp/8/8/8/8/PPPPPPPP/R2QK2R w KQkq - 0 1")
        _ = try game.make(from: 4, to: 5)
        _ = try game.make(from: 60, to: 61)
        XCTAssertThrowsError(try game.make(from: 5, to: 7, type: .castleKingSide))
    }

    func testValidQueenSideCastling() {
        let game = Game(fen: "r3k2r/8/8/8/8/8/8/R3K2R w Q - 0 1")
        XCTAssertTrue(try game.make(move: "O-O-O"))
    }

    // MARK: - FEN Correctness After Castling
    //
    // Regression tests for the bug where castling only moved the king
    // and left the rook on its original square (see `Game.make(move:)`).
    // Each of these tests asserts the full resulting FEN — most importantly
    // the rook's final square and the remaining castling rights.

    func testWhiteKingSideCastlingProducesCorrectFEN() throws {
        let game = Game(fen: "r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")

        XCTAssertTrue(try game.make(move: "O-O"))

        // King e1 → g1, Rook h1 → f1. White loses both castling rights.
        XCTAssertEqual(
            game.fen(),
            "r3k2r/8/8/8/8/8/8/R4RK1 b kq - 0 1"
        )
    }

    func testWhiteQueenSideCastlingProducesCorrectFEN() throws {
        let game = Game(fen: "r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")

        XCTAssertTrue(try game.make(move: "O-O-O"))

        // King e1 → c1, Rook a1 → d1. White loses both castling rights.
        XCTAssertEqual(
            game.fen(),
            "r3k2r/8/8/8/8/8/8/2KR3R b kq - 0 1"
        )
    }

    func testBlackKingSideCastlingProducesCorrectFEN() throws {
        let game = Game(fen: "r3k2r/8/8/8/8/8/8/R3K2R b KQkq - 0 1")

        XCTAssertTrue(try game.make(move: "O-O"))

        // King e8 → g8, Rook h8 → f8. Black loses both castling rights.
        XCTAssertEqual(
            game.fen(),
            "r4rk1/8/8/8/8/8/8/R3K2R w KQ - 0 1"
        )
    }

    func testBlackQueenSideCastlingProducesCorrectFEN() throws {
        let game = Game(fen: "r3k2r/8/8/8/8/8/8/R3K2R b KQkq - 0 1")

        XCTAssertTrue(try game.make(move: "O-O-O"))

        // King e8 → c8, Rook a8 → d8. Black loses both castling rights.
        XCTAssertEqual(
            game.fen(),
            "2kr3r/8/8/8/8/8/8/R3K2R w KQ - 0 1"
        )
    }

    /// Exact scenario reported by the user:
    /// 1. d4 Nf6 2. e4 Nxe4 3. Bd3 d5 4. Nf3 c5 5. O-O cxd4
    ///
    /// Before the fix, the resulting back-rank was `RNBQ2KR`
    /// (white rook stuck on h1). After the fix it is `RNBQ1RK1`.
    func testUserReportedCastlingScenarioProducesCorrectFEN() throws {
        let game = Game()

        XCTAssertTrue(try game.make(move: "d4"))
        XCTAssertTrue(try game.make(move: "Nf6"))
        XCTAssertTrue(try game.make(move: "e4"))
        XCTAssertTrue(try game.make(move: "Nxe4"))
        XCTAssertTrue(try game.make(move: "Bd3"))
        XCTAssertTrue(try game.make(move: "d5"))
        XCTAssertTrue(try game.make(move: "Nf3"))
        XCTAssertTrue(try game.make(move: "c5"))
        XCTAssertTrue(try game.make(move: "O-O"))
        XCTAssertTrue(try game.make(move: "cxd4"))

        XCTAssertEqual(
            game.fen(),
            "rnbqkb1r/pp2pppp/8/3p4/3pn3/3B1N2/PPP2PPP/RNBQ1RK1 w kq - 0 1"
        )
    }

    /// Same scenario as above but stopping right after `5. O-O`
    /// (the precise board state the user pasted in the bug report).
    func testCastlingScenarioPositionImmediatelyAfterCastling() throws {
        let game = Game()

        XCTAssertTrue(try game.make(move: "d4"))
        XCTAssertTrue(try game.make(move: "Nf6"))
        XCTAssertTrue(try game.make(move: "e4"))
        XCTAssertTrue(try game.make(move: "Nxe4"))
        XCTAssertTrue(try game.make(move: "Bd3"))
        XCTAssertTrue(try game.make(move: "d5"))
        XCTAssertTrue(try game.make(move: "Nf3"))
        XCTAssertTrue(try game.make(move: "c5"))
        XCTAssertTrue(try game.make(move: "O-O"))

        XCTAssertEqual(
            game.fen(),
            "rnbqkb1r/pp2pppp/8/2pp4/3Pn3/3B1N2/PPP2PPP/RNBQ1RK1 b kq - 0 1"
        )
    }

    // MARK: - Castling also clears castling rights

    func testCastlingClearsBothCastlingRightsForWhite() throws {
        let game = Game(fen: "r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")

        XCTAssertTrue(try game.make(move: "O-O"))

        XCTAssertFalse(game.board.castlingRights.whiteKingSide)
        XCTAssertFalse(game.board.castlingRights.whiteQueenSide)
        XCTAssertTrue(game.board.castlingRights.blackKingSide)
        XCTAssertTrue(game.board.castlingRights.blackQueenSide)
    }

    func testCastlingClearsBothCastlingRightsForBlack() throws {
        let game = Game(fen: "r3k2r/8/8/8/8/8/8/R3K2R b KQkq - 0 1")

        XCTAssertTrue(try game.make(move: "O-O-O"))

        XCTAssertTrue(game.board.castlingRights.whiteKingSide)
        XCTAssertTrue(game.board.castlingRights.whiteQueenSide)
        XCTAssertFalse(game.board.castlingRights.blackKingSide)
        XCTAssertFalse(game.board.castlingRights.blackQueenSide)
    }

    // MARK: - Castling places pieces on the expected indices

    func testWhiteKingSideCastlingPlacesKingAndRookOnCorrectSquares() throws {
        let game = Game(fen: "r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")

        XCTAssertTrue(try game.make(move: "O-O"))

        // 6 = g1 (king), 5 = f1 (rook)
        XCTAssertEqual(game.board.squares[6]?.type, .king)
        XCTAssertEqual(game.board.squares[6]?.color, .white)
        XCTAssertEqual(game.board.squares[5]?.type, .rook)
        XCTAssertEqual(game.board.squares[5]?.color, .white)
        // Origin squares must be empty now
        XCTAssertNil(game.board.squares[4]) // e1
        XCTAssertNil(game.board.squares[7]) // h1
    }

    func testBlackQueenSideCastlingPlacesKingAndRookOnCorrectSquares() throws {
        let game = Game(fen: "r3k2r/8/8/8/8/8/8/R3K2R b KQkq - 0 1")

        XCTAssertTrue(try game.make(move: "O-O-O"))

        // 58 = c8 (king), 59 = d8 (rook)
        XCTAssertEqual(game.board.squares[58]?.type, .king)
        XCTAssertEqual(game.board.squares[58]?.color, .black)
        XCTAssertEqual(game.board.squares[59]?.type, .rook)
        XCTAssertEqual(game.board.squares[59]?.color, .black)
        // Origin squares must be empty now
        XCTAssertNil(game.board.squares[60]) // e8
        XCTAssertNil(game.board.squares[56]) // a8
    }
}
