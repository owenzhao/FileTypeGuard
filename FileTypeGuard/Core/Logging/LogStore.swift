import Foundation

/// 日志存储和查询
final class LogStore {

    // MARK: - Singleton

    static let shared = LogStore()
    private init() {
        cleanupOldLogs()
    }

    // MARK: - Properties

    private let fileManager = FileManager.default
    private let logger = EventLogger.shared

    /// 日志目录
    private var logDirectoryURL: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport
            .appendingPathComponent("FileTypeGuard")
            .appendingPathComponent("logs")
    }

    // MARK: - Query Filter

    struct QueryFilter {
        var startDate: Date?
        var endDate: Date?
        var eventType: LogEntry.EventType?
        var fileType: String?
        var searchText: String?

        static var all: QueryFilter {
            return QueryFilter()
        }
    }

    // MARK: - Public Methods

    /// 查询日志
    /// - Parameters:
    ///   - filter: 筛选条件
    ///   - limit: 返回条数限制
    /// - Returns: 符合条件的日志条目
    func getLogs(filter: QueryFilter = .all, limit: Int? = nil) -> [LogEntry] {
        var allLogs: [LogEntry] = []

        // 获取所有日志文件
        let logFiles = getLogFiles()

        for fileURL in logFiles {
            if let logs = readLogsFromFile(fileURL) {
                allLogs.append(contentsOf: logs)
            }
        }

        // 应用筛选
        var filtered = allLogs

        if let startDate = filter.startDate {
            filtered = filtered.filter { $0.timestamp >= startDate }
        }

        if let endDate = filter.endDate {
            filtered = filtered.filter { $0.timestamp <= endDate }
        }

        if let eventType = filter.eventType {
            filtered = filtered.filter { $0.eventType == eventType }
        }

        if let fileType = filter.fileType {
            filtered = filtered.filter { $0.fileType == fileType }
        }

        if let searchText = filter.searchText, !searchText.isEmpty {
            filtered = filtered.filter { entry in
                entry.fileTypeName.localizedCaseInsensitiveContains(searchText) ||
                entry.fromAppName?.localizedCaseInsensitiveContains(searchText) == true ||
                entry.toAppName.localizedCaseInsensitiveContains(searchText)
            }
        }

        // 按时间倒序排序
        filtered.sort()

        // 限制返回数量
        if let limit = limit {
            return Array(filtered.prefix(limit))
        }

        return filtered
    }

    /// 获取日志统计
    func getStatistics() -> LogStatistics {
        let logs = getLogs()

        let totalCount = logs.count
        let restoredCount = logs.filter { $0.eventType == .restored }.count
        let failedCount = logs.filter { $0.eventType == .restoreFailed }.count

        return LogStatistics(
            totalCount: totalCount,
            restoredCount: restoredCount,
            failedCount: failedCount
        )
    }

    /// 清理旧日志（超过指定天数）
    func cleanupOldLogs(retentionDays: Int = 30) {
        let logFiles = getLogFiles()
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -retentionDays, to: Date())!

        for fileURL in logFiles {
            // 从文件名提取日期
            let fileName = fileURL.deletingPathExtension().lastPathComponent
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            if let fileDate = dateFormatter.date(from: fileName) {
                if fileDate < cutoffDate {
                    do {
                        try fileManager.removeItem(at: fileURL)
                        print("🗑️  已删除过期日志: \(fileName)")
                    } catch {
                        print("❌ 删除日志文件失败: \(error)")
                    }
                }
            }
        }
    }

    // MARK: - Private Methods

    /// 获取所有日志文件
    private func getLogFiles() -> [URL] {
        do {
            let files = try fileManager.contentsOfDirectory(
                at: logDirectoryURL,
                includingPropertiesForKeys: nil
            )

            return files.filter { $0.pathExtension == "log" }
                .sorted { $0.lastPathComponent > $1.lastPathComponent }  // 按日期倒序

        } catch {
            print("❌ 读取日志目录失败: \(error)")
            return []
        }
    }

    /// 从文件读取日志
    private func readLogsFromFile(_ fileURL: URL) -> [LogEntry]? {
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            var logs: [LogEntry] = []

            for line in lines {
                guard !line.isEmpty else { continue }

                if let data = line.data(using: .utf8),
                   let entry = try? decoder.decode(LogEntry.self, from: data) {
                    logs.append(entry)
                }
            }

            return logs

        } catch {
            print("❌ 读取日志文件失败: \(error)")
            return nil
        }
    }
}

// MARK: - Log Statistics

struct LogStatistics {
    let totalCount: Int
    let restoredCount: Int
    let failedCount: Int

    var successRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(restoredCount) / Double(totalCount)
    }
}
