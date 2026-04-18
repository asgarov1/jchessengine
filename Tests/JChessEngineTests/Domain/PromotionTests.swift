//
//  PromotionTests.swift
//  JChessEngine
//
//  Covers pawn promotion handling (Option B: auto-queen when the user
//  omits the `=X` suffix from SAN, explicit piece when they include it).
//
import XCTest
import JChessEngine

final class PromotionTests: XCTestCase {

    // MARK: - SAN parsing

    func testSanParserExtractsExplicitQueenPromotion() throws {
        // A white pawn on e7 pushing to e8 with explicit queen promotion.
        var board = Board()
        board.squares[MoveUtil.squareIndex("e7")] = Piece(type: .pawn, color: .white)
        board.squares[MoveUtil.squareIndex("e1")] = Piece(type: .king, color: .white)
        board.squares[MoveUtil.squareIndex("a8")] = Piece(type: .king, color: .black)
        board.sideToMove = .white

        let move = try Move(san: "e8=Q", board: board)

        XCTAssertEqual(move.from, MoveUtil.squareIndex("e7"))
        XCTAssertEqual(move.to, MoveUtil.squareIndex("e8"))
        XCTAssertEqual(move.promotionPiece, .queen)
    }

    func testSanParserExtractsKnightUnderpromotion() throws {
        var board = Board()
        board.squares[MoveUtil.squareIndex("e7")] = Piece(type: .pawn, color: .white)
        board.squares[MoveUtil.squareIndex("e1")] = Piece(type: .king, color: .white)
        board.squares[MoveUtil.squareIndex("a8")] = Piece(type: .king, color: .black)
        board.sideToMove = .white

        let move = try Move(san: "e8=N", board: board)
        XCTAssertEqual(move.promotionPiece, .knight)
    }

    func testSanParserExtractsRookUnderpromotion() throws {
        var board = Board()
        board.squares[MoveUtil.squareIndex("e7")] = Piece(type: .pawn, color: .white)
        board.squares[MoveUtil.squareIndex("e1")] = Piece(type: .king, color: .white)
        board.squares[MoveUtil.squareIndex("a8")] = Piece(type: .king, color: .black)
        board.sideToMove = .white

        let move = try Move(san: "e8=R", board: board)
        XCTAssertEqual(move.promotionPiece, .rook)
    }

    func testSanParserExtractsBishopUnderpromotion() throws {
        var board = Board()
        board.squares[MoveUtil.squareIndex("e7")] = Piece(type: .pawn, color: .white)
        board.squares[MoveUtil.squareIndex("e1")] = Piece(type: .king, color: .white)
        board.squares[MoveUtil.squareIndex("a8")] = Piece(type: .king, color: .black)
        board.sideToMove = .white

        let move = try Move(san: "e8=B", board: board)
        XCTAssertEqual(move.promotionPiece, .bishop)
    }

    func testSanParserPromotionWithCapture() throws {
        // exd8=Q style — pawn on e7 captures onto d8 and promotes to queen.
        var board = Board()
        board.squares[MoveUtil.squareIndex("e7")] = Piece(type: .pawn, color: .white)
        board.squares[MoveUtil.squareIndex("d8")] = Piece(type: .rook, color: .black)
        board.squares[MoveUtil.squareIndex("e1")] = Piece(type: .king, color: .white)
        board.squares[MoveUtil.squareIndex("a1")] = Piece(type: .king, color: .black)
        board.sideToMove = .white

        let move = try Move(san: "exd8=Q", board: board)

        XCTAssertEqual(move.from, MoveUtil.squareIndex("e7"))
        XCTAssertEqual(move.to, MoveUtil.squareIndex("d8"))
        XCTAssertEqual(move.promotionPiece, .queen)
    }

    func testSanParserPromotionWithCaptureAndCheck() throws {
        // exd8=Q+ — parser should strip + then still recognise =Q.
        var board = Board()
        board.squares[MoveUtil.squareIndex("e7")] = Piece(type: .pawn, color: .white)
        board.squares[MoveUtil.squareIndex("d8")] = Piece(type: .rook, color: .black)
        board.squares[MoveUtil.squareIndex("e1")] = Piece(type: .king, color: .white)
        board.squares[MoveUtil.squareIndex("e8")] = Piece(type: .king, color: .black)
        board.sideToMove = .white

        let move = try Move(san: "exd8=Q+", board: board)

        XCTAssertEqual(move.to, MoveUtil.squareIndex("d8"))
        XCTAssertEqual(move.promotionPiece, .queen)
    }

    func testSanParserMissingPromotionLeavesPromotionPieceNil() throws {
        // User typed `exd8+` without `=Q`. Parsing should succeed and
        // promotionPiece should be nil (auto-queen is applied later by Game.make).
        var board = Board()
        board.squares[MoveUtil.squareIndex("e7")] = Piece(type: .pawn, color: .white)
        board.squares[MoveUtil.squareIndex("d8")] = Piece(type: .rook, color: .black)
        board.squares[MoveUtil.squareIndex("e1")] = Piece(type: .king, color: .white)
        board.squares[MoveUtil.squareIndex("e8")] = Piece(type: .king, color: .black)
        board.sideToMove = .white

        let move = try Move(san: "exd8+", board: board)

        XCTAssertEqual(move.to, MoveUtil.squareIndex("d8"))
        XCTAssertNil(move.promotionPiece)
    }

    func testSanParserInvalidPromotionPieceThrows() {
        // `=K` (king) is not a legal promotion piece.
        var board = Board()
        board.squares[MoveUtil.squareIndex("e7")] = Piece(type: .pawn, color: .white)
        board.squares[MoveUtil.squareIndex("e1")] = Piece(type: .king, color: .white)
        board.squares[MoveUtil.squareIndex("a8")] = Piece(type: .king, color: .black)
        board.sideToMove = .white

        XCTAssertThrowsError(try Move(san: "e8=K", board: board))
    }

    // MARK: - Game.make application

    func testGameAppliesExplicitQueenPromotion() throws {
        let game = Game(fen: "k7/4P3/8/8/8/8/8/4K3 w - - 0 1")

        XCTAssertTrue(try game.make(move: "e8=Q"))

        let piece = game.board.squares[MoveUtil.squareIndex("e8")]
        XCTAssertEqual(piece?.type, .queen)
        XCTAssertEqual(piece?.color, .white)
    }

    func testGameAppliesExplicitKnightPromotion() throws {
        let game = Game(fen: "k7/4P3/8/8/8/8/8/4K3 w - - 0 1")

        XCTAssertTrue(try game.make(move: "e8=N"))

        XCTAssertEqual(game.board.squares[MoveUtil.squareIndex("e8")]?.type, .knight)
    }

    /// The original bug: pawn reached 8th rank but the move SAN carried no
    /// `=X` suffix, and the engine silently left a pawn on d8. After the fix
    /// we auto-promote to queen.
    func testGameAutoQueensWhenPromotionSuffixOmitted() throws {
        // White pawn on e7, Black rook on d8, capture onto d8 without `=Q`.
        let game = Game(fen: "3rk3/4P3/8/8/8/8/8/4K3 w - - 0 1")

        XCTAssertTrue(try game.make(move: "exd8+"))

        let piece = game.board.squares[MoveUtil.squareIndex("d8")]
        XCTAssertEqual(piece?.type, .queen, "missing promotion suffix must auto-queen")
        XCTAssertEqual(piece?.color, .white)
    }

    func testGameAutoQueensOnQuietPushWithoutSuffix() throws {
        let game = Game(fen: "k7/4P3/8/8/8/8/8/4K3 w - - 0 1")

        XCTAssertTrue(try game.make(move: "e8"))

        XCTAssertEqual(game.board.squares[MoveUtil.squareIndex("e8")]?.type, .queen)
    }

    func testGameAutoQueensForBlackPawn() throws {
        // Black pawn on e2 pushing to e1 with no suffix — must auto-queen (black).
        // White king lives on h1 so the e1 square is empty for the push.
        let game = Game(fen: "4k3/8/8/8/8/8/4p3/7K b - - 0 1")

        XCTAssertTrue(try game.make(move: "e1"))

        let piece = game.board.squares[MoveUtil.squareIndex("e1")]
        XCTAssertEqual(piece?.type, .queen)
        XCTAssertEqual(piece?.color, .black)
    }

    /// When we auto-promote we also normalise the recorded SAN so PGN output
    /// reflects what actually happened on the board.
    func testGameNormalisesSanWhenAutoQueening() throws {
        let game = Game(fen: "3rk3/4P3/8/8/8/8/8/4K3 w - - 0 1")

        XCTAssertTrue(try game.make(move: "exd8+"))

        let recorded = game.board.moveHistory.last
        XCTAssertEqual(recorded?.san, "exd8=Q+")
        XCTAssertEqual(recorded?.promotionPiece, .queen)
    }

    func testGameKeepsExplicitSanWhenUserSuppliedIt() throws {
        let game = Game(fen: "3rk3/4P3/8/8/8/8/8/4K3 w - - 0 1")

        XCTAssertTrue(try game.make(move: "exd8=Q+"))

        let recorded = game.board.moveHistory.last
        XCTAssertEqual(recorded?.san, "exd8=Q+")
        XCTAssertEqual(recorded?.promotionPiece, .queen)
    }

    func testGameRespectsExplicitUnderpromotion() throws {
        let game = Game(fen: "k7/4P3/8/8/8/8/8/4K3 w - - 0 1")

        XCTAssertTrue(try game.make(move: "e8=N"))

        XCTAssertEqual(game.board.squares[MoveUtil.squareIndex("e8")]?.type, .knight)
        XCTAssertEqual(game.board.moveHistory.last?.promotionPiece, .knight)
    }

    // MARK: - Regression: full game from the bug report

    /// Reproduces the exact game the user hit, up to and including move 23
    /// white (`exd8+`). After that move d8 must hold a white queen (not a
    /// pawn — that was the bug).
    ///
    /// Note: the user's 23…Re7 reply is intentionally *not* played here.
    /// Before the fix, the pawn-on-d8 delivered no check, so Re7 was legal;
    /// after the fix the auto-queened piece *does* check the black king,
    /// and Re7 no longer resolves the check. That behaviour change is
    /// itself a sign the fix is working.
    func testBugReportGameResultsInQueenOnD8() throws {
        let game = Game()

        let moves = [
            "e4", "a6",
            "b4", "e5",
            "a3", "Nf6",
            "Bc4", "Nxe4",
            "d3", "Nf6",
            "Bb2", "b5",
            "Bb3", "Ke7",
            "Nf3", "Ra7",
            "O-O", "d6",
            "Re1", "Ke8",
            "Nbd2", "Be7",
            "Ne4", "Nxe4",
            "Re4", "g6",
            "d4", "d5",
            "Re5", "Bf5",
            "Qe2", "Nd7",
            "Rd5", "c6",
            "Rf5", "gxf5",
            "d5", "f6",
            "d6", "c5",
            "bxc5", "Nxc5",
            "dxe7", "Rb7",
            "exd8+"          // white move 23 — the one that exposed the bug
        ]

        for san in moves {
            XCTAssertTrue(
                try game.make(move: san),
                "Expected `\(san)` to be accepted as legal"
            )
        }

        let d8 = game.board.squares[MoveUtil.squareIndex("d8")]
        XCTAssertEqual(d8?.type, .queen, "d8 must be a queen after auto-promotion")
        XCTAssertEqual(d8?.color, .white)

        // And the resulting check on black's king should now be real —
        // a queen on d8 attacks e8 diagonally/orthogonally adjacent.
        XCTAssertTrue(
            game.isKingInCheck(color: .black),
            "auto-queened piece on d8 should be checking the black king"
        )
    }
}
