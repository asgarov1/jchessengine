//
//  AlgebraicMove.swift
//  JChessEngine
//
//  Created by Javid Asgarov on 14.01.26.
//
public struct AlgebraicMove {
    public let piece: PieceType
    public let destination: Int
    public let fileHint: Int?
    public let rankHint: Int?
    public let isCapture: Bool
    public let promotion: PieceType?
    public let castling: MoveType?

    public init(
        piece: PieceType,
        destination: Int,
        fileHint: Int?,
        rankHint: Int?,
        isCapture: Bool,
        promotion: PieceType?,
        castling: MoveType?
    ) {
        self.piece = piece
        self.destination = destination
        self.fileHint = fileHint
        self.rankHint = rankHint
        self.isCapture = isCapture
        self.promotion = promotion
        self.castling = castling
    }
}
