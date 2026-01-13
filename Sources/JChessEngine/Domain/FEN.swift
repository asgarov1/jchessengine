
public enum FEN {
    public static func load(fen: String, into board: inout Board) {
        let parts = fen.split(separator: " ")
        let rows = parts[0].split(separator: "/")
        var index = 56

        for row in rows {
            var file = 0
            for char in row {
                if let empty = char.wholeNumberValue {
                    file += empty
                } else {
                    let color: Color = char.isUppercase ? .white : .black
                    let type = PieceType(rawValue: String(char).lowercased())!
                    board.squares[index + file] = Piece(type: type, color: color)
                    file += 1
                }
            }
            index -= 8
        }

        board.sideToMove = parts[1] == "w" ? .white : .black
        board.castlingRights = CastlingRights()
        if parts.count > 2 {
            let c = parts[2]
            board.castlingRights.whiteKingSide = c.contains("K")
            board.castlingRights.whiteQueenSide = c.contains("Q")
            board.castlingRights.blackKingSide = c.contains("k")
            board.castlingRights.blackQueenSide = c.contains("q")
        }
    }

    public static func export(board: Board) -> String {
        var rows: [String] = []
        for rank in (0..<8).reversed() {
            var row = ""
            var empty = 0
            for file in 0..<8 {
                let sq = rank * 8 + file
                if let piece = board.squares[sq] {
                    if empty > 0 { row += String(empty); empty = 0 }
                    let c = piece.type.rawValue
                    row += piece.color == .white ? c.uppercased() : c
                } else {
                    empty += 1
                }
            }
            if empty > 0 { row += String(empty) }
            rows.append(row)
        }

        var castling = ""
        if board.castlingRights.whiteKingSide { castling += "K" }
        if board.castlingRights.whiteQueenSide { castling += "Q" }
        if board.castlingRights.blackKingSide { castling += "k" }
        if board.castlingRights.blackQueenSide { castling += "q" }
        if castling.isEmpty { castling = "-" }

        return rows.joined(separator: "/")
            + " " + board.sideToMove.rawValue
            + " " + castling
            + " - 0 1"
    }
}
