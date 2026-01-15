//
//  MovementUtil.swift
//  JChessEngine
//
//  Created by Javid Asgarov on 14.01.26.
//
public final class MoveUtil {
    
    public static func isPathClear(from: Int, to: Int, board: Board) -> Bool {
        let fromFile = from % 8
        let fromRank = from / 8
        let toFile = to % 8
        let toRank = to / 8

        let stepFile = (toFile - fromFile).signum()
        let stepRank = (toRank - fromRank).signum()

        var file = fromFile + stepFile
        var rank = fromRank + stepRank

        while file != toFile || rank != toRank {
            let sq = rank * 8 + file
            if board.squares[sq] != nil {
                return false
            }
            file += stepFile
            rank += stepRank
        }

        return true
    }
}
