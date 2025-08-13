import Foundation

final class DbSizeLogger {
    static func logDbRowSize(_ row: [String: Any], name: String = "", tag: String = "db_row_size", log: Bool = true) {
        let sizeBytes = RowSizeBenchmark.getRowSizeInBytes(row: row)
        let sizeKB = RowSizeBenchmark.getRowSizeInKB(row: row)

        if log {
            print("\(tag) | Row size for \(name): \(sizeBytes) bytes (\(String(format: "%.2f", sizeKB)) KB)")
        }
    }

    static func logTotalDbRowSize(_ rows: [[String: Any]], name: String = "", tag: String = "db_row_size", log: Bool = true) {
        let totalBytes = rows.reduce(0) { $0 + RowSizeBenchmark.getRowSizeInBytes(row: $1) }
        let totalKB = Double(totalBytes) / 1024.0

        if log {
            print("\(tag) | Total row size for \(name): \(totalBytes) bytes (\(String(format: "%.2f", totalKB)) KB)")
        }
    }
}


