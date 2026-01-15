
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
    
    public init(squares: [Piece?], sideToMove: Color, castlingRights: CastlingRights) {
        self.init()
        self.squares = squares
        self.sideToMove = sideToMove
        self.castlingRights = castlingRights
    }
    
    public func kingSquare(of color: Color) -> Int {
        for i in 0..<64 {
            if let piece = squares[i],
               piece.type == .king,
               piece.color == color {
                return i
            }
        }
        return -1 // can't really happen
    }
    
    func copy() -> Board {
        Board(
            squares: self.squares,
            sideToMove: self.sideToMove,
            castlingRights: self.castlingRights
        )
    }
    
    public static func startingPosition() -> Board {
        Board(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    }
}
