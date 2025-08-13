import Foundation

final class ExecutionLogger {
    @discardableResult
    static func logExecDuration<T>(name: String = "no_name", tag: String = "no_tag", log: Bool = true, _ action: () throws -> T) rethrows -> T {
        let start = Date()
        let result = try action()
        let elapsed = Date().timeIntervalSince(start) * 1000.0
        if log {
            print("\(tag) | Execution time for \(name): \(String(format: "%.0f", elapsed)) ms")
        }
        return result
    }

    static func logExecDurationAsync<T>(name: String = "no_name", tag: String = "no_tag", log: Bool = true, _ action: @escaping () async throws -> T) async rethrows -> T {
        let start = Date()
        let result = try await action()
        let elapsed = Date().timeIntervalSince(start) * 1000.0
        if log {
            print("\(tag) | Execution time for \(name): \(String(format: "%.0f", elapsed)) ms")
        }
        return result
    }
}


