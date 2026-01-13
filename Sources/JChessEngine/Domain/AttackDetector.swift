
public enum AttackDetector {
    public static func isSquareAttacked(_ square: Int, by color: Color, board: Board) -> Bool {
        for i in 0..<64 {
            guard let p = board.squares[i], p.color == color else { continue }
            let dx = abs((i % 8) - (square % 8))
            let dy = abs((i / 8) - (square / 8))

            switch p.type {
            case .rook:
                if dx == 0 || dy == 0 { return true }
            case .bishop:
                if dx == dy { return true }
            case .queen:
                if dx == dy || dx == 0 || dy == 0 { return true }
            case .knight:
                if (dx == 1 && dy == 2) || (dx == 2 && dy == 1) { return true }
            case .king:
                if dx <= 1 && dy <= 1 { return true }
            case .pawn:
                let dir = (p.color == .white) ? 1 : -1
                if dy == 1 && dx == 1 && ((square / 8) - (i / 8)) == dir {
                    return true
                }
            }
        }
        return false
    }
}
