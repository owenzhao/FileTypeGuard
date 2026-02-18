import Foundation

/// 保护规则模型
struct ProtectionRule: Identifiable, Codable, Hashable {

    // MARK: - Properties

    let id: UUID
    var fileType: FileType
    var expectedApplication: Application
    var isEnabled: Bool
    let createdAt: Date
    var lastVerified: Date?
    var notes: String?

    // MARK: - Computed Properties

    var displayName: String {
        return "\(fileType.localizedDisplayName) → \(expectedApplication.name)"
    }

    var statusDescription: String {
        if isEnabled {
            if let lastVerified = lastVerified {
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .short
                let timeString = formatter.localizedString(for: lastVerified, relativeTo: Date())
                return String(localized: "enabled") + " • " + String(localized: "last verified: \(timeString)")
            }
            return String(localized: "enabled")
        }
        return String(localized: "disabled")
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        fileType: FileType,
        expectedApplication: Application,
        isEnabled: Bool = true,
        createdAt: Date = Date(),
        lastVerified: Date? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.fileType = fileType
        self.expectedApplication = expectedApplication
        self.isEnabled = isEnabled
        self.createdAt = createdAt
        self.lastVerified = lastVerified
        self.notes = notes
    }

    // MARK: - Validation

    /// 验证规则是否有效（应用是否仍存在）
    func isValid() -> Bool {
        return expectedApplication.isInstalled()
    }

    /// 更新最后验证时间
    mutating func updateLastVerified() {
        self.lastVerified = Date()
    }
}

// MARK: - CustomStringConvertible

extension ProtectionRule: CustomStringConvertible {
    var description: String {
        return displayName
    }
}

// MARK: - Comparable

extension ProtectionRule: Comparable {
    static func < (lhs: ProtectionRule, rhs: ProtectionRule) -> Bool {
        // 按文件类型名称排序
        return lhs.fileType < rhs.fileType
    }
}

// MARK: - Convenience Extensions

extension ProtectionRule {

    /// 创建示例规则（用于预览和测试）
    static var preview: ProtectionRule {
        let fileType = FileType(
            uti: "com.adobe.pdf",
            extensions: [".pdf"],
            displayName: "PDF Document"
        )

        let app = Application(
            bundleID: "com.apple.Preview",
            name: "Preview",
            path: "/System/Applications/Preview.app"
        )

        return ProtectionRule(
            fileType: fileType,
            expectedApplication: app
        )
    }
}
