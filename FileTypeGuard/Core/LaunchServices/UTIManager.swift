import Foundation
import UniformTypeIdentifiers

/// UTI (Uniform Type Identifier) 管理器
/// 负责文件扩展名和 UTI 之间的转换
final class UTIManager {

    // MARK: - Singleton

    static let shared = UTIManager()
    private init() {}

    // MARK: - Error Types

    enum UTIError: Error {
        case invalidExtension
        case invalidUTI
        case notFound

        var localizedDescription: String {
            switch self {
            case .invalidExtension:
                return "无效的文件扩展名"
            case .invalidUTI:
                return "无效的 UTI"
            case .notFound:
                return "未找到对应的 UTI 或扩展名"
            }
        }
    }

    // MARK: - Extension to UTI

    /// 根据文件扩展名获取 UTI
    /// - Parameter extension: 文件扩展名，如 ".pdf" 或 "pdf"
    /// - Returns: UTI 字符串，如 "com.adobe.pdf"
    func getUTI(forExtension extension: String) -> String? {
        var ext = `extension`

        // 移除前导的点号
        if ext.hasPrefix(".") {
            ext = String(ext.dropFirst())
        }

        guard !ext.isEmpty else {
            return nil
        }

        // 使用 UniformTypeIdentifiers (macOS 11+)
        if let utType = UTType(filenameExtension: ext) {
            return utType.identifier
        }

        return nil
    }

    /// 根据文件扩展名获取 UTType
    /// - Parameter extension: 文件扩展名
    /// - Returns: UTType 对象
    @available(macOS 11.0, *)
    func getUTType(forExtension extension: String) -> UTType? {
        var ext = `extension`

        if ext.hasPrefix(".") {
            ext = String(ext.dropFirst())
        }

        guard !ext.isEmpty else {
            return nil
        }

        return UTType(filenameExtension: ext)
    }

    // MARK: - UTI to Extensions

    /// 根据 UTI 获取所有关联的文件扩展名
    /// - Parameter uti: UTI 字符串，如 "com.adobe.pdf"
    /// - Returns: 文件扩展名数组，如 [".pdf"]
    func getExtensions(forUTI uti: String) -> [String] {
        guard !uti.isEmpty else {
            return []
        }

        // 使用 UniformTypeIdentifiers
        guard let utType = UTType(uti) else {
            return []
        }

        // 获取首选扩展名
        var extensions: [String] = []

        if let preferredExt = utType.preferredFilenameExtension {
            extensions.append(".\(preferredExt)")
        }

        // 获取所有标签（包括扩展名）
        if let tags = utType.tags[.filenameExtension] {
            for tag in tags {
                let ext = ".\(tag)"
                if !extensions.contains(ext) {
                    extensions.append(ext)
                }
            }
        }

        return extensions
    }

    /// 获取 UTI 的首选文件扩展名
    /// - Parameter uti: UTI 字符串
    /// - Returns: 首选扩展名，如 ".pdf"
    func getPreferredExtension(forUTI uti: String) -> String? {
        guard !uti.isEmpty else {
            return nil
        }

        guard let utType = UTType(uti) else {
            return nil
        }

        if let ext = utType.preferredFilenameExtension {
            return ".\(ext)"
        }

        return nil
    }

    // MARK: - UTI Information

    /// 获取 UTI 的本地化描述
    /// - Parameter uti: UTI 字符串
    /// - Returns: 本地化描述，如 "PDF 文档"
    func getDescription(forUTI uti: String) -> String? {
        guard !uti.isEmpty else {
            return nil
        }

        guard let utType = UTType(uti) else {
            return nil
        }

        return utType.localizedDescription
    }

    /// 验证 UTI 是否有效
    /// - Parameter uti: UTI 字符串
    /// - Returns: 是否有效
    func isValidUTI(_ uti: String) -> Bool {
        guard !uti.isEmpty else {
            return false
        }

        return UTType(uti) != nil
    }

    /// 获取 UTI 的父类型
    /// - Parameter uti: UTI 字符串
    /// - Returns: 父类型 UTI 数组
    func getSupertypes(forUTI uti: String) -> [String] {
        guard !uti.isEmpty else {
            return []
        }

        guard let utType = UTType(uti) else {
            return []
        }

        return utType.supertypes.map { $0.identifier }
    }

    // MARK: - Common UTIs

    /// 常见文件类型的 UTI 映射
    static let commonUTIs: [String: String] = [
        // 文档
        ".pdf": "com.adobe.pdf",
        ".doc": "com.microsoft.word.doc",
        ".docx": "org.openxmlformats.wordprocessingml.document",
        ".txt": "public.plain-text",
        ".rtf": "public.rtf",
        ".md": "net.daringfireball.markdown",

        // 图片
        ".jpg": "public.jpeg",
        ".jpeg": "public.jpeg",
        ".png": "public.png",
        ".gif": "com.compuserve.gif",
        ".bmp": "com.microsoft.bmp",
        ".tiff": "public.tiff",
        ".svg": "public.svg-image",
        ".webp": "org.webmproject.webp",

        // 视频
        ".mp4": "public.mpeg-4",
        ".mov": "com.apple.quicktime-movie",
        ".avi": "public.avi",
        ".mkv": "org.matroska.mkv",
        ".flv": "com.adobe.flash.video",

        // 音频
        ".mp3": "public.mp3",
        ".wav": "com.microsoft.waveform-audio",
        ".aac": "public.aac-audio",
        ".flac": "org.xiph.flac",
        ".m4a": "public.mpeg-4-audio",

        // 压缩包
        ".zip": "public.zip-archive",
        ".rar": "com.rarlab.rar-archive",
        ".7z": "org.7-zip.7-zip-archive",
        ".tar": "public.tar-archive",
        ".gz": "org.gnu.gnu-zip-archive",

        // 代码
        ".swift": "public.swift-source",
        ".py": "public.python-script",
        ".js": "com.netscape.javascript-source",
        ".html": "public.html",
        ".css": "public.css",
        ".json": "public.json",
        ".xml": "public.xml",

        // 其他
        ".app": "com.apple.application-bundle",
        ".dmg": "com.apple.disk-image"
    ]

    /// 根据扩展名快速查找常见 UTI（无需系统查询）
    /// - Parameter extension: 文件扩展名
    /// - Returns: UTI 字符串，如果不在常见列表中则返回 nil
    func getCommonUTI(forExtension extension: String) -> String? {
        var ext = `extension`

        if !ext.hasPrefix(".") {
            ext = ".\(ext)"
        }

        return Self.commonUTIs[ext.lowercased()]
    }
}

// MARK: - Convenience Methods

extension UTIManager {

    /// 便捷方法：同时获取 UTI 和描述
    /// - Parameter extension: 文件扩展名
    /// - Returns: (UTI, 描述) 元组
    func getUTIInfo(forExtension extension: String) -> (uti: String, description: String?)? {
        guard let uti = getUTI(forExtension: `extension`) else {
            return nil
        }

        let description = getDescription(forUTI: uti)
        return (uti, description)
    }

    /// 验证文件扩展名是否有效
    /// - Parameter extension: 文件扩展名
    /// - Returns: 是否有效（能找到对应的 UTI）
    func isValidExtension(_ extension: String) -> Bool {
        return getUTI(forExtension: `extension`) != nil
    }
}
