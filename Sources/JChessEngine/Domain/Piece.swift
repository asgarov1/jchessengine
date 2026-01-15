
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
    
    static func fromSAN(_ c: Character) -> PieceType {
        switch c {
        case "N": return .knight
        case "B": return .bishop
        case "R": return .rook
        case "Q": return .queen
        case "K": return .king
        default:
            fatalError("Invalid SAN piece: \(c)")
        }
    }
    
    var sanLetter: String {
            switch self {
            case .king:   return "K"
            case .queen:  return "Q"
            case .rook:   return "R"
            case .bishop: return "B"
            case .knight: return "N"
            case .pawn:   return ""
            }
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
