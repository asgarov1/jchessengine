
public enum AttackDetector {
    public static func isSquareAttacked(_ square: String, by color: Color, board: Board) -> Bool {
        let squareAsInt = CoordinateUtil.squareIndex(square)
        return isSquareAttacked(squareAsInt, by: color, board: board)
    }
    
    public static func isSquareAttacked(_ square: Int, by color: Color, board: Board) -> Bool {
        let tx = square % 8
        let ty = square / 8

        for i in 0..<64 {
            guard let p = board.squares[i], p.color == color else { continue }

            let fx = i % 8
            let fy = i / 8
            let dx = tx - fx
            let dy = ty - fy

            switch p.type {

            case .rook:
                if dx == 0 {
                    if MoveUtil.isPathClear(from: i, to: square, board: board) {
                        return true
                    }
                } else if dy == 0 {
                    if  MoveUtil.isPathClear(from: i, to: square, board: board) {
                        return true
                    }
                }

            case .bishop:
                if abs(dx) == abs(dy) {
                    if  MoveUtil.isPathClear(from: i, to: square, board: board) {
                        return true
                    }
                }

            case .queen:
                if dx == 0 || dy == 0 || abs(dx) == abs(dy) {
                    if  MoveUtil.isPathClear(from: i, to: square, board: board) {
                        return true
                    }
                }

            case .knight:
                if (abs(dx) == 1 && abs(dy) == 2) || (abs(dx) == 2 && abs(dy) == 1) {
                    return true
                }

            case .king:
                if abs(dx) <= 1 && abs(dy) <= 1 {
                    return true
                }

            case .pawn:
                let dir = (p.color == .white) ? 1 : -1
                if abs(dx) == 1 && dy == dir {
                    return true
                }
            }
        }
        return false
    }
}
