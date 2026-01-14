
public enum AttackDetector {
    public static func isSquareAttacked(_ square: String, by color: Color, board: Board) -> Bool {
        let squareAsInt = AttackDetector.squareIndex(square)
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
                    let stepY = dy > 0 ? 1 : -1
                    if isPathClear(from: i, to: square, stepX: 0, stepY: stepY, board: board) {
                        return true
                    }
                } else if dy == 0 {
                    let stepX = dx > 0 ? 1 : -1
                    if isPathClear(from: i, to: square, stepX: stepX, stepY: 0, board: board) {
                        return true
                    }
                }

            case .bishop:
                if abs(dx) == abs(dy) {
                    let stepX = dx > 0 ? 1 : -1
                    let stepY = dy > 0 ? 1 : -1
                    if isPathClear(from: i, to: square, stepX: stepX, stepY: stepY, board: board) {
                        return true
                    }
                }

            case .queen:
                if dx == 0 || dy == 0 || abs(dx) == abs(dy) {
                    let stepX = dx == 0 ? 0 : (dx > 0 ? 1 : -1)
                    let stepY = dy == 0 ? 0 : (dy > 0 ? 1 : -1)
                    if isPathClear(from: i, to: square, stepX: stepX, stepY: stepY, board: board) {
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

    
    private static func isPathClear(from: Int, to: Int, stepX: Int, stepY: Int, board: Board) -> Bool {
        var x = (from % 8) + stepX
        var y = (from / 8) + stepY

        let targetX = to % 8
        let targetY = to / 8

        while x != targetX || y != targetY {
            let idx = y * 8 + x
            if board.squares[idx] != nil {
                return false
            }
            x += stepX
            y += stepY
        }
        return true
    }

    
    public static func squareIndex(_ algebraic: String) -> Int {
        precondition(algebraic.count == 2, "Invalid algebraic notation")

        let chars = Array(algebraic.lowercased())
        let fileChar = chars[0]
        let rankChar = chars[1]

        precondition(fileChar >= "a" && fileChar <= "h", "Invalid file")
        precondition(rankChar >= "1" && rankChar <= "8", "Invalid rank")

        let file = Int(fileChar.asciiValue! - Character("a").asciiValue!)
        let rank = Int(rankChar.asciiValue! - Character("1").asciiValue!)

        return rank * 8 + file
    }
}
