import Foundation

/// 日志条目数据模型
struct LogEntry: Identifiable, Codable, Hashable {

    // MARK: - Properties

    let id: UUID
    let timestamp: Date
    let eventType: EventType
    let fileType: String  // UTI
    let fileTypeName: String  // 显示名称
    let fromApp: String?  // 旧应用 Bundle ID
    let fromAppName: String?  // 旧应用名称
    let toApp: String  // 新应用 Bundle ID
    let toAppName: String  // 新应用名称
    let status: Status
    let errorMessage: String?

    // MARK: - Event Type

    enum EventType: String, Codable {
        case detected       // 检测到变化
        case restored       // 恢复成功
        case restoreFailed  // 恢复失败
        case userModified   // 用户手动修改

        var displayName: String {
            switch self {
            case .detected:
                return String(localized: "change_detected")
            case .restored:
                return String(localized: "restore_success")
            case .restoreFailed:
                return String(localized: "restore_failed")
            case .userModified:
                return String(localized: "user_modified")
            }
        }

        var icon: String {
            switch self {
            case .detected:
                return "exclamationmark.triangle"
            case .restored:
                return "checkmark.circle.fill"
            case .restoreFailed:
                return "xmark.circle.fill"
            case .userModified:
                return "person.fill"
            }
        }
    }

    // MARK: - Status

    enum Status: String, Codable {
        case success
        case failed
        case pending

        var displayName: String {
            switch self {
            case .success:
                return String(localized: "success")
            case .failed:
                return String(localized: "failed")
            case .pending:
                return String(localized: "pending")
            }
        }
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        eventType: EventType,
        fileType: String,
        fileTypeName: String,
        fromApp: String?,
        fromAppName: String?,
        toApp: String,
        toAppName: String,
        status: Status,
        errorMessage: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.eventType = eventType
        self.fileType = fileType
        self.fileTypeName = fileTypeName
        self.fromApp = fromApp
        self.fromAppName = fromAppName
        self.toApp = toApp
        self.toAppName = toAppName
        self.status = status
        self.errorMessage = errorMessage
    }

    // MARK: - Computed Properties

    var description: String {
        let from = fromAppName ?? String(localized: "unknown_app")
        let to = toAppName
        return String(localized: "\(fileTypeName) \(from) → \(to)")
    }

    var detailDescription: String {
        var detail = description
        if let error = errorMessage {
            detail += "\n" + String(localized: "error: \(error)")
        }
        return detail
    }
}

// MARK: - Comparable

extension LogEntry: Comparable {
    static func < (lhs: LogEntry, rhs: LogEntry) -> Bool {
        // 按时间倒序排列（最新的在最前面）
        return lhs.timestamp > rhs.timestamp
    }
}

// MARK: - Convenience Extensions

extension LogEntry {

    /// 创建示例日志（用于预览和测试）
    static var preview: LogEntry {
        return LogEntry(
            eventType: .restored,
            fileType: "com.adobe.pdf",
            fileTypeName: "PDF Document",
            fromApp: "com.adobe.Reader",
            fromAppName: "Adobe Acrobat Reader",
            toApp: "com.apple.Preview",
            toAppName: "Preview",
            status: .success
        )
    }

    static var previewFailed: LogEntry {
        return LogEntry(
            eventType: .restoreFailed,
            fileType: "com.adobe.pdf",
            fileTypeName: "PDF Document",
            fromApp: "com.adobe.Reader",
            fromAppName: "Adobe Acrobat Reader",
            toApp: "com.apple.Preview",
            toAppName: "Preview",
            status: .failed,
            errorMessage: "权限不足，无法设置文件关联"
        )
    }
}
