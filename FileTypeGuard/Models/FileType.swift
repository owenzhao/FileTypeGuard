import Foundation

/// 文件类型模型
struct FileType: Identifiable, Codable, Hashable {

    // MARK: - Properties

    let id: UUID
    let uti: String
    let extensions: [String]
    var displayName: String

    /// 本地化显示名称：优先从 CommonFileTypes 查找本地化名称，否则用存储的 displayName
    var localizedDisplayName: String {
        if let preset = CommonFileTypes.find(uti: uti) {
            return preset.displayName
        }
        return displayName
    }

    // MARK: - Computed Properties

    /// 主要扩展名（第一个）
    var primaryExtension: String? {
        return extensions.first
    }

    /// 扩展名字符串（用于显示）
    var extensionsString: String {
        return extensions.joined(separator: ", ")
    }

    // MARK: - Initialization

    init(id: UUID = UUID(), uti: String, extensions: [String], displayName: String? = nil) {
        self.id = id
        self.uti = uti
        self.extensions = extensions
        self.displayName = displayName ?? extensions.first ?? uti
    }

    // MARK: - Factory Methods

    /// 从扩展名创建文件类型
    static func from(extension ext: String) -> FileType? {
        guard let uti = UTIManager.shared.getUTI(forExtension: ext) else {
            return nil
        }

        let extensions = UTIManager.shared.getExtensions(forUTI: uti)
        let description = UTIManager.shared.getDescription(forUTI: uti)

        return FileType(
            uti: uti,
            extensions: extensions.isEmpty ? [ext] : extensions,
            displayName: description ?? ext
        )
    }

    /// 从 UTI 创建文件类型
    static func from(uti: String) -> FileType? {
        guard UTIManager.shared.isValidUTI(uti) else {
            return nil
        }

        let extensions = UTIManager.shared.getExtensions(forUTI: uti)
        let description = UTIManager.shared.getDescription(forUTI: uti)

        return FileType(
            uti: uti,
            extensions: extensions,
            displayName: description ?? uti
        )
    }
}

// MARK: - CustomStringConvertible

extension FileType: CustomStringConvertible {
    var description: String {
        return "\(displayName) (\(extensionsString))"
    }
}

// MARK: - Comparable

extension FileType: Comparable {
    static func < (lhs: FileType, rhs: FileType) -> Bool {
        return lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
    }
}
