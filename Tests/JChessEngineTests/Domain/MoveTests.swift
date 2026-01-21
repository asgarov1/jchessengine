//
//  MoveTests.swift
//  JChessEngine
//
//  Created by Javid Asgarov on 15.01.26.
//
import XCTest
import JChessEngine

final class MoveTests: XCTestCase {
    
    func testKingSideCastlingWithLetterO() throws {
        let board = Board.startingPosition()
        let kingFrom = board.kingSquare(of: board.sideToMove)
        
        let move = try Move(san: "O-O", board: board)
        
        XCTAssertEqual(move.from, kingFrom)
        XCTAssertEqual(move.to, kingFrom + 2)
        XCTAssertEqual(move.type, .castleKingSide)
    }
    
    func testKingSideCastlingWithZero() throws {
        let board = Board.startingPosition()
        let kingFrom = board.kingSquare(of: board.sideToMove)
        
        let move = try Move(san: "0-0", board: board)
        
        XCTAssertEqual(move.from, kingFrom)
        XCTAssertEqual(move.to, kingFrom + 2)
        XCTAssertEqual(move.type, .castleKingSide)
    }
    
    func testQueenSideCastlingWithLetterO() throws {
        let board = Board.startingPosition()
        let kingFrom = board.kingSquare(of: board.sideToMove)
        
        let move = try Move(san: "O-O-O", board: board)
        
        XCTAssertEqual(move.from, kingFrom)
        XCTAssertEqual(move.to, kingFrom - 2)
        XCTAssertEqual(move.type, .castleQueenSide)
    }
    
    func testQueenSideCastlingWithZero() throws {
        let board = Board.startingPosition()
        let kingFrom = board.kingSquare(of: board.sideToMove)
        
        let move = try Move(san: "0-0-0", board: board)
        
        XCTAssertEqual(move.from, kingFrom)
        XCTAssertEqual(move.to, kingFrom - 2)
        XCTAssertEqual(move.type, .castleQueenSide)
    }
    
    func testSanStripsCheckSymbol() throws {
        let board = Board.startingPosition()
        
        print(MoveValidator.isLegal(from: "e2", to: "e4", type: .normal, on: board))
        
        let moveWithoutCheck = try Move(san: "e4", board: board)
        let moveWithCheck = try Move(san: "e4+", board: board)
        
        XCTAssertEqual(moveWithoutCheck.from, moveWithCheck.from)
        XCTAssertEqual(moveWithoutCheck.to, moveWithCheck.to)
        XCTAssertEqual(moveWithoutCheck.type, moveWithCheck.type)
    }
    
    func testSanStripsCheckmateSymbol() throws {
        var board = Board()
        board.squares[CoordinateUtil.squareIndex("b1")] = Piece(type: .queen, color: .white)
        
        let moveWithoutMate = try Move(san: "Qh7", board: board)
        let moveWithMate = try Move(san: "Qh7#", board: board)
        
        XCTAssertEqual(moveWithoutMate.from, moveWithMate.from)
        XCTAssertEqual(moveWithoutMate.to, moveWithMate.to)
        XCTAssertEqual(moveWithoutMate.type, moveWithMate.type)
    }
    
    func testNormalSanMoveResolvesCorrectly() throws {
        let board = Board.startingPosition()
        
        let move = try Move(san: "e4", board: board)
        
        XCTAssertEqual(move.type, .normal)
        XCTAssertEqual(move.from, MoveUtil.squareIndex("e2"))
        XCTAssertEqual(move.to, MoveUtil.squareIndex("e4"))
    }
}
