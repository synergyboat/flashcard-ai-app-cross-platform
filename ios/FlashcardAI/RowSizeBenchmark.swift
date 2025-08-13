import Foundation

enum RowSizeBenchmark {
    static func getRowSizeInBytes(row: [String: Any]) -> Int {
        if JSONSerialization.isValidJSONObject(row),
           let data = try? JSONSerialization.data(withJSONObject: row, options: []) {
            return data.count
        }
        return 0
    }

    static func getRowSizeInKB(row: [String: Any]) -> Double {
        Double(getRowSizeInBytes(row: row)) / 1024.0
    }

    static func getRowSizeInBytes<T: Encodable>(_ row: T) -> Int {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(row) {
            return data.count
        }
        return 0
    }

    static func getRowSizeInKB<T: Encodable>(_ row: T) -> Double {
        Double(getRowSizeInBytes(row)) / 1024.0
    }
}


