
public struct CastlingRights {
    public var whiteKingSide = true
    public var whiteQueenSide = true
    public var blackKingSide = true
    public var blackQueenSide = true
}

public struct Board {
    public var squares: [Piece?] = Array(repeating: nil, count: 64)
    public var sideToMove: Color = .white
    public var castlingRights = CastlingRights()

    public init() {}

    public init(fen: String) {
        self.init()
        FEN.load(fen: fen, into: &self)
    }
}
