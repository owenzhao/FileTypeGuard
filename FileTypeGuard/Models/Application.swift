import Foundation
import AppKit

/// 应用模型
struct Application: Identifiable, Codable, Hashable {

    // MARK: - Properties

    let bundleID: String
    var name: String
    var path: String
    var version: String?

    // MARK: - Computed Properties

    var id: String {
        return bundleID
    }

    var pathURL: URL {
        return URL(fileURLWithPath: path)
    }

    var displayName: String {
        if let version = version {
            return "\(name) (\(version))"
        }
        return name
    }

    // MARK: - Initialization

    init(bundleID: String, name: String, path: String, version: String? = nil) {
        self.bundleID = bundleID
        self.name = name
        self.path = path
        self.version = version
    }

    // MARK: - Factory Methods

    /// 从 Bundle ID 创建应用
    static func from(bundleID: String) -> Application? {
        guard let appInfo = ApplicationResolver.shared.resolveApplication(bundleID: bundleID) else {
            return nil
        }

        return Application(
            bundleID: appInfo.bundleID,
            name: appInfo.name,
            path: appInfo.path.path,
            version: appInfo.version
        )
    }

    /// 从 ApplicationInfo 创建应用
    static func from(appInfo: ApplicationResolver.ApplicationInfo) -> Application {
        return Application(
            bundleID: appInfo.bundleID,
            name: appInfo.name,
            path: appInfo.path.path,
            version: appInfo.version
        )
    }

    // MARK: - Validation

    /// 验证应用是否仍然存在
    func isInstalled() -> Bool {
        return ApplicationResolver.shared.isApplicationInstalled(bundleID: bundleID)
    }

    /// 获取应用图标（非持久化）
    func getIcon() -> NSImage? {
        return ApplicationResolver.shared.getApplicationIcon(bundleID: bundleID)
    }
}

// MARK: - CustomStringConvertible

extension Application: CustomStringConvertible {
    var description: String {
        return "\(name) (\(bundleID))"
    }
}

// MARK: - Comparable

extension Application: Comparable {
    static func < (lhs: Application, rhs: Application) -> Bool {
        return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
    }
}
