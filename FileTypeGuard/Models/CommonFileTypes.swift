import Foundation

/// 常见文件类型预设清单
struct CommonFileTypes {

    /// 文件类型分类
    enum Category: String, CaseIterable, Identifiable {
        case documents
        case images
        case videos
        case audio
        case archives
        case code
        case data

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .documents: return String(localized: "category_documents")
            case .images: return String(localized: "category_images")
            case .videos: return String(localized: "category_videos")
            case .audio: return String(localized: "category_audio")
            case .archives: return String(localized: "category_archives")
            case .code: return String(localized: "category_code")
            case .data: return String(localized: "category_data")
            }
        }

        var icon: String {
            switch self {
            case .documents: return "doc.text.fill"
            case .images: return "photo.fill"
            case .videos: return "video.fill"
            case .audio: return "waveform"
            case .archives: return "archivebox.fill"
            case .code: return "chevron.left.forwardslash.chevron.right"
            case .data: return "tablecells.fill"
            }
        }
    }

    /// 预设文件类型定义
    struct PresetFileType: Identifiable, Hashable {
        let id = UUID()
        let displayName: String
        let extensions: [String]
        let uti: String
        let category: Category
        let icon: String

        /// 转换为 FileType
        func toFileType() -> FileType {
            FileType(
                uti: uti,
                extensions: extensions,
                displayName: displayName
            )
        }
    }

    // MARK: - 预设列表

    static let allTypes: [PresetFileType] = [
        // 文档类
        PresetFileType(
            displayName: String(localized: "filetype_pdf_document"),
            extensions: [".pdf"],
            uti: "com.adobe.pdf",
            category: .documents,
            icon: "doc.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_word_document"),
            extensions: [".doc", ".docx"],
            uti: "org.openxmlformats.wordprocessingml.document",
            category: .documents,
            icon: "doc.text.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_excel_spreadsheet"),
            extensions: [".xls", ".xlsx"],
            uti: "org.openxmlformats.spreadsheetml.sheet",
            category: .documents,
            icon: "tablecells.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_powerpoint_presentation"),
            extensions: [".ppt", ".pptx"],
            uti: "org.openxmlformats.presentationml.presentation",
            category: .documents,
            icon: "chart.bar.doc.horizontal.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_text_file"),
            extensions: [".txt"],
            uti: "public.plain-text",
            category: .documents,
            icon: "doc.plaintext.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_rtf_document"),
            extensions: [".rtf"],
            uti: "public.rtf",
            category: .documents,
            icon: "doc.richtext.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_markdown_document"),
            extensions: [".md", ".markdown"],
            uti: "net.daringfireball.markdown",
            category: .documents,
            icon: "text.alignleft"
        ),

        // 图片类
        PresetFileType(
            displayName: String(localized: "filetype_jpeg_image"),
            extensions: [".jpg", ".jpeg"],
            uti: "public.jpeg",
            category: .images,
            icon: "photo.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_png_image"),
            extensions: [".png"],
            uti: "public.png",
            category: .images,
            icon: "photo.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_gif_image"),
            extensions: [".gif"],
            uti: "com.compuserve.gif",
            category: .images,
            icon: "photo.on.rectangle.angled"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_webp_image"),
            extensions: [".webp"],
            uti: "org.webmproject.webp",
            category: .images,
            icon: "photo.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_svg_image"),
            extensions: [".svg"],
            uti: "public.svg-image",
            category: .images,
            icon: "SquareCompactLayout"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_heic_image"),
            extensions: [".heic"],
            uti: "public.heic",
            category: .images,
            icon: "photo.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_photoshop_file"),
            extensions: [".psd"],
            uti: "com.adobe.photoshop-image",
            category: .images,
            icon: "photo.artframe"
        ),

        // 视频类
        PresetFileType(
            displayName: String(localized: "filetype_mp4_video"),
            extensions: [".mp4"],
            uti: "public.mpeg-4",
            category: .videos,
            icon: "video.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_mov_video"),
            extensions: [".mov"],
            uti: "com.apple.quicktime-movie",
            category: .videos,
            icon: "video.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_avi_video"),
            extensions: [".avi"],
            uti: "public.avi",
            category: .videos,
            icon: "video.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_mkv_video"),
            extensions: [".mkv"],
            uti: "org.matroska.mkv",
            category: .videos,
            icon: "video.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_webm_video"),
            extensions: [".webm"],
            uti: "org.webmproject.webm",
            category: .videos,
            icon: "video.fill"
        ),

        // 音频类
        PresetFileType(
            displayName: String(localized: "filetype_mp3_audio"),
            extensions: [".mp3"],
            uti: "public.mp3",
            category: .audio,
            icon: "waveform"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_aac_audio"),
            extensions: [".aac", ".m4a"],
            uti: "public.aac-audio",
            category: .audio,
            icon: "waveform"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_flac_audio"),
            extensions: [".flac"],
            uti: "org.xiph.flac",
            category: .audio,
            icon: "waveform"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_wav_audio"),
            extensions: [".wav"],
            uti: "com.microsoft.waveform-audio",
            category: .audio,
            icon: "waveform"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_ogg_audio"),
            extensions: [".ogg"],
            uti: "org.xiph.ogg-audio",
            category: .audio,
            icon: "waveform"
        ),

        // 压缩包类
        PresetFileType(
            displayName: String(localized: "filetype_zip_archive"),
            extensions: [".zip"],
            uti: "public.zip-archive",
            category: .archives,
            icon: "archivebox.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_rar_archive"),
            extensions: [".rar"],
            uti: "com.rarlab.rar-archive",
            category: .archives,
            icon: "archivebox.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_7z_archive"),
            extensions: [".7z"],
            uti: "org.7-zip.7-zip-archive",
            category: .archives,
            icon: "archivebox.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_tar_archive"),
            extensions: [".tar"],
            uti: "public.tar-archive",
            category: .archives,
            icon: "archivebox.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_gz_archive"),
            extensions: [".gz", ".tar.gz"],
            uti: "org.gnu.gnu-zip-archive",
            category: .archives,
            icon: "archivebox.fill"
        ),

        // 代码类
        PresetFileType(
            displayName: String(localized: "filetype_swift_code"),
            extensions: [".swift"],
            uti: "public.swift-source",
            category: .code,
            icon: "chevron.left.forwardslash.chevron.right"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_python_code"),
            extensions: [".py"],
            uti: "public.python-script",
            category: .code,
            icon: "chevron.left.forwardslash.chevron.right"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_javascript_code"),
            extensions: [".js"],
            uti: "com.netscape.javascript-source",
            category: .code,
            icon: "chevron.left.forwardslash.chevron.right"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_typescript_code"),
            extensions: [".ts"],
            uti: "public.typescript-source",
            category: .code,
            icon: "chevron.left.forwardslash.chevron.right"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_html_file"),
            extensions: [".html", ".htm"],
            uti: "public.html",
            category: .code,
            icon: "chevron.left.forwardslash.chevron.right"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_css_stylesheet"),
            extensions: [".css"],
            uti: "public.css",
            category: .code,
            icon: "paintbrush.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_java_code"),
            extensions: [".java"],
            uti: "com.sun.java-source",
            category: .code,
            icon: "chevron.left.forwardslash.chevron.right"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_c_cpp_code"),
            extensions: [".c", ".cpp", ".h", ".hpp"],
            uti: "public.c-source",
            category: .code,
            icon: "chevron.left.forwardslash.chevron.right"
        ),

        // 数据类
        PresetFileType(
            displayName: String(localized: "filetype_json_data"),
            extensions: [".json"],
            uti: "public.json",
            category: .data,
            icon: "tablecells.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_xml_data"),
            extensions: [".xml"],
            uti: "public.xml",
            category: .data,
            icon: "tablecells.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_csv_data"),
            extensions: [".csv"],
            uti: "public.comma-separated-values-text",
            category: .data,
            icon: "tablecells.fill"
        ),
        PresetFileType(
            displayName: String(localized: "filetype_yaml_data"),
            extensions: [".yaml", ".yml"],
            uti: "public.yaml",
            category: .data,
            icon: "tablecells.fill"
        ),
    ]

    // MARK: - 辅助方法

    /// 按分类组织文件类型
    static func typesByCategory() -> [Category: [PresetFileType]] {
        var result: [Category: [PresetFileType]] = [:]

        for category in Category.allCases {
            result[category] = allTypes.filter { $0.category == category }
        }

        return result
    }

    /// 查找文件类型
    static func find(extension ext: String) -> PresetFileType? {
        allTypes.first { $0.extensions.contains(ext.lowercased()) }
    }

    /// 查找文件类型
    static func find(uti: String) -> PresetFileType? {
        allTypes.first { $0.uti == uti }
    }
}
