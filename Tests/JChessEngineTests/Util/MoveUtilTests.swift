//
//  MoveUtilTests.swift
//  JChessEngine
//
//  Created by Javid Asgarov on 15.01.26.
//
import XCTest
import JChessEngine

final class MoveUtilTests: XCTestCase {
    
    func testThatMoveGetsCorrectlyParsedToSan() {
        let board = Board.startingPosition()
        
        let testCases: [(move: Move, expectedSan: String)] = [
            (Move(from: "d2", to: "d4"), "d4"),
            (Move(from: "e2", to: "e4"), "e4"),
            (Move(from: "g1", to: "f3"), "Nf3")
        ]
        
        for testCase in testCases {
            let board = Board.startingPosition()
            let san = MoveUtil.san(for: testCase.move, on: board)
            
            XCTAssertEqual(
                san,
                testCase.expectedSan,
                "Incorrect SAN for move \(testCase.move)"
            )
        }
    }
}
