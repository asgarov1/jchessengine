//
//  MoveUtilTests.swift
//  JChessEngine
//
//  Created by Javid Asgarov on 15.01.26.
//
import XCTest
import JChessEngine

final class SanUtilTests: XCTestCase {
    
    func testThatMoveGetsCorrectlyParsedToSan() {
        let board = Board.startingPosition()
        
        XCTAssertEqual(SanUtil.san(from: "d2", to: "d4", type: .normal, on: board), "d4")
        XCTAssertEqual(SanUtil.san(from: "e2", to: "e4", type: .normal, on: board), "e4")
        XCTAssertEqual(SanUtil.san(from: "g1", to: "f3", type: .normal, on: board), "Nf3")
    }
}
