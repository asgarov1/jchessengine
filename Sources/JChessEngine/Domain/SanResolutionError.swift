//
//  SanResolutionError.swift
//  JChessEngine
//
//  Created by Javid Asgarov on 15.01.26.
//
enum SANResolutionError: Error, CustomStringConvertible {
    case illegalMove(String)
    case ambiguousMove(String, candidates: [Move])
    case noMatchingMove(String)

    var description: String {
        switch self {
        case .illegalMove(let san):
            return "Illegal SAN move: \(san)"
        case .ambiguousMove(let san, let candidates):
            return "Ambiguous SAN move '\(san)': \(candidates)"
        case .noMatchingMove(let san):
            return "No matching move for SAN: \(san)"
        }
    }
}
