
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
}
