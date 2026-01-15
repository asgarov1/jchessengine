//
//  MoveTests.swift
//  JChessEngine
//
//  Created by Javid Asgarov on 15.01.26.
//
import XCTest
import JChessEngine

final class MoveTests: XCTestCase {
    
    func testKingSideCastlingWithLetterO() {
        let board = Board.startingPosition()
        let kingFrom = board.kingSquare(of: board.sideToMove)
        
        let move = Move(san: "O-O", board: board)
        
        XCTAssertEqual(move.from, kingFrom)
        XCTAssertEqual(move.to, kingFrom + 2)
        XCTAssertEqual(move.type, .castleKingSide)
    }
    
    func testKingSideCastlingWithZero() {
        let board = Board.startingPosition()
        let kingFrom = board.kingSquare(of: board.sideToMove)
        
        let move = Move(san: "0-0", board: board)
        
        XCTAssertEqual(move.from, kingFrom)
        XCTAssertEqual(move.to, kingFrom + 2)
        XCTAssertEqual(move.type, .castleKingSide)
    }
    
    func testQueenSideCastlingWithLetterO() {
        let board = Board.startingPosition()
        let kingFrom = board.kingSquare(of: board.sideToMove)
        
        let move = Move(san: "O-O-O", board: board)
        
        XCTAssertEqual(move.from, kingFrom)
        XCTAssertEqual(move.to, kingFrom - 2)
        XCTAssertEqual(move.type, .castleQueenSide)
    }
    
    func testQueenSideCastlingWithZero() {
        let board = Board.startingPosition()
        let kingFrom = board.kingSquare(of: board.sideToMove)
        
        let move = Move(san: "0-0-0", board: board)
        
        XCTAssertEqual(move.from, kingFrom)
        XCTAssertEqual(move.to, kingFrom - 2)
        XCTAssertEqual(move.type, .castleQueenSide)
    }
    
    func testSanStripsCheckSymbol() {
        let board = Board.startingPosition()
        
        print(MoveValidator.isLegal(move: Move(from: "e2", to: "e4"), on: board))
        
        let moveWithoutCheck = Move(san: "e4", board: board)
        let moveWithCheck = Move(san: "e4+", board: board)
        
        XCTAssertEqual(moveWithoutCheck.from, moveWithCheck.from)
        XCTAssertEqual(moveWithoutCheck.to, moveWithCheck.to)
        XCTAssertEqual(moveWithoutCheck.type, moveWithCheck.type)
    }
    
    func testSanStripsCheckmateSymbol() {
        var board = Board()
        board.squares[CoordinateUtil.squareIndex("b1")] = Piece(type: .queen, color: .white)
        
        let moveWithoutMate = Move(san: "Qh7", board: board)
        let moveWithMate = Move(san: "Qh7#", board: board)
        
        XCTAssertEqual(moveWithoutMate.from, moveWithMate.from)
        XCTAssertEqual(moveWithoutMate.to, moveWithMate.to)
        XCTAssertEqual(moveWithoutMate.type, moveWithMate.type)
    }
    
    func testNormalSanMoveResolvesCorrectly() {
        let board = Board.startingPosition()
        
        let move = Move(san: "e4", board: board)
        
        XCTAssertEqual(move.type, .normal)
        XCTAssertEqual(move.from, Move.squareIndex("e2"))
        XCTAssertEqual(move.to, Move.squareIndex("e4"))
    }
}
