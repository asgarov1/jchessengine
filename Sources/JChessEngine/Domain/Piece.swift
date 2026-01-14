
public enum Color: String {
    case white = "w"
    case black = "b"
    
    public var opposite: Color {
        self == .white ? .black : .white
    }
}

public enum PieceType: String {
    case pawn = "p", knight = "n", bishop = "b", rook = "r", queen = "q", king = "k"
    
    var isSliding: Bool {
        self == .rook || self == .bishop || self == .queen
    }
}

public struct Piece {
    public let type: PieceType
    public let color: Color
    
    public init(type: PieceType, color: Color) {
        self.type = type
        self.color = color
    }
}
