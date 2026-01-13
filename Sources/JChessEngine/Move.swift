
public enum MoveType {
    case normal
    case castleKingSide
    case castleQueenSide
}

public struct Move {
    public let from: Int
    public let to: Int
    public let type: MoveType

    public init(from: Int, to: Int, type: MoveType = .normal) {
        self.from = from
        self.to = to
        self.type = type
    }
    
    public init(from: String, to: String, type: MoveType = .normal) {
        self.from = Move.squareIndex(from)
        self.to = Move.squareIndex(to)
        self.type = type
    }

    private static func squareIndex(_ s: String) -> Int {
        let chars = Array(s.lowercased())
        let file = Int(chars[0].unicodeScalars.first!.value - Character("a").unicodeScalars.first!.value)
        let rank = Int(chars[1].unicodeScalars.first!.value - Character("1").unicodeScalars.first!.value)
        return rank * 8 + file
    }
}
