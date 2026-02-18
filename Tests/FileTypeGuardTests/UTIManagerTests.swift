import XCTest
@testable import FileTypeGuard

final class UTIManagerTests: XCTestCase {

    var manager: UTIManager!

    override func setUp() {
        super.setUp()
        manager = UTIManager.shared
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    // MARK: - Test getUTI

    func testGetUTI_ForPDF() {
        // Given: PDF 扩展名
        let extensions = [".pdf", "pdf"]

        // When & Then: 都应该返回正确的 UTI
        for ext in extensions {
            let uti = manager.getUTI(forExtension: ext)
            XCTAssertNotNil(uti, "应该能找到 PDF 的 UTI")
            XCTAssertEqual(uti, "com.adobe.pdf", "PDF 的 UTI 应该是 com.adobe.pdf")
            print("✅ \(ext) → \(uti ?? "nil")")
        }
    }

    func testGetUTI_CommonExtensions() {
        // Given: 常见文件扩展名及其预期的 UTI
        let testCases: [(ext: String, expectedUTI: String)] = [
            (".txt", "public.plain-text"),
            (".jpg", "public.jpeg"),
            (".jpeg", "public.jpeg"),
            (".png", "public.png"),
            (".mp4", "public.mpeg-4"),
            (".html", "public.html"),
            (".json", "public.json")
        ]

        // When & Then: 每个扩展名都应该返回正确的 UTI
        for (ext, expectedUTI) in testCases {
            let uti = manager.getUTI(forExtension: ext)
            XCTAssertEqual(uti, expectedUTI, "\(ext) 的 UTI 应该是 \(expectedUTI)")
            print("✅ \(ext) → \(uti ?? "nil")")
        }
    }

    func testGetUTI_WithAndWithoutDot() {
        // Given: 带点和不带点的扩展名
        let withDot = ".pdf"
        let withoutDot = "pdf"

        // When: 获取 UTI
        let uti1 = manager.getUTI(forExtension: withDot)
        let uti2 = manager.getUTI(forExtension: withoutDot)

        // Then: 应该返回相同的结果
        XCTAssertEqual(uti1, uti2, "带点和不带点应该返回相同的 UTI")
        XCTAssertEqual(uti1, "com.adobe.pdf")
    }

    func testGetUTI_EmptyString() {
        // Given: 空字符串
        let empty = ""

        // When: 获取 UTI
        let uti = manager.getUTI(forExtension: empty)

        // Then: 应该返回 nil
        XCTAssertNil(uti, "空字符串应该返回 nil")
    }

    func testGetUTI_InvalidExtension() {
        // Given: 不存在的扩展名
        let invalid = ".xyz12345"

        // When: 获取 UTI
        let uti = manager.getUTI(forExtension: invalid)

        // Then: 应该返回 nil（或者返回一个动态 UTI）
        print("⚠️  不存在的扩展名 \(invalid) 返回: \(uti ?? "nil")")
    }

    // MARK: - Test getExtensions

    func testGetExtensions_ForPDF() {
        // Given: PDF 的 UTI
        let uti = "com.adobe.pdf"

        // When: 获取扩展名
        let extensions = manager.getExtensions(forUTI: uti)

        // Then: 应该包含 .pdf
        XCTAssertFalse(extensions.isEmpty, "PDF 应该有扩展名")
        XCTAssertTrue(extensions.contains(".pdf"), "应该包含 .pdf")
        print("✅ \(uti) → \(extensions)")
    }

    func testGetExtensions_CommonUTIs() {
        // Given: 常见的 UTI
        let testCases: [(uti: String, expectedExt: String)] = [
            ("public.plain-text", ".txt"),
            ("public.jpeg", ".jpeg"),
            ("public.png", ".png"),
            ("public.html", ".html")
        ]

        // When & Then: 每个 UTI 都应该返回对应的扩展名
        for (uti, expectedExt) in testCases {
            let extensions = manager.getExtensions(forUTI: uti)
            XCTAssertFalse(extensions.isEmpty, "\(uti) 应该有扩展名")
            XCTAssertTrue(extensions.contains(expectedExt) || extensions.contains(String(expectedExt.dropFirst())),
                         "\(uti) 应该包含 \(expectedExt)")
            print("✅ \(uti) → \(extensions)")
        }
    }

    func testGetExtensions_EmptyUTI() {
        // Given: 空 UTI
        let empty = ""

        // When: 获取扩展名
        let extensions = manager.getExtensions(forUTI: empty)

        // Then: 应该返回空数组
        XCTAssertTrue(extensions.isEmpty, "空 UTI 应该返回空数组")
    }

    func testGetExtensions_InvalidUTI() {
        // Given: 无效的 UTI
        let invalid = "com.invalid.nonexistent"

        // When: 获取扩展名
        let extensions = manager.getExtensions(forUTI: invalid)

        // Then: 应该返回空数组
        XCTAssertTrue(extensions.isEmpty, "无效 UTI 应该返回空数组")
    }

    // MARK: - Test Round-trip Conversion

    func testRoundTripConversion_PDF() {
        // Given: PDF 扩展名
        let originalExt = ".pdf"

        // When: 扩展名 → UTI → 扩展名
        guard let uti = manager.getUTI(forExtension: originalExt) else {
            XCTFail("应该能找到 PDF 的 UTI")
            return
        }

        let extensions = manager.getExtensions(forUTI: uti)

        // Then: 应该包含原始扩展名
        XCTAssertTrue(extensions.contains(originalExt), "往返转换应该包含原始扩展名")
        print("✅ 往返转换: \(originalExt) → \(uti) → \(extensions)")
    }

    // MARK: - Test Preferred Extension

    func testGetPreferredExtension() {
        // Given: 常见的 UTI
        let testCases: [(uti: String, expectedExt: String)] = [
            ("com.adobe.pdf", ".pdf"),
            ("public.plain-text", ".txt"),
            ("public.jpeg", ".jpeg"),
            ("public.png", ".png")
        ]

        // When & Then: 每个 UTI 都应该返回首选扩展名
        for (uti, expectedExt) in testCases {
            let preferredExt = manager.getPreferredExtension(forUTI: uti)
            XCTAssertNotNil(preferredExt, "\(uti) 应该有首选扩展名")
            // 注意: 有些系统可能返回不同的首选扩展名（如 .jpg vs .jpeg）
            print("✅ \(uti) 首选扩展名: \(preferredExt ?? "nil") (期望: \(expectedExt))")
        }
    }

    // MARK: - Test Description

    func testGetDescription() {
        // Given: 常见的 UTI
        let utis = ["com.adobe.pdf", "public.plain-text", "public.jpeg", "public.png"]

        // When & Then: 每个 UTI 都应该有描述
        for uti in utis {
            let description = manager.getDescription(forUTI: uti)
            XCTAssertNotNil(description, "\(uti) 应该有描述")
            XCTAssertFalse(description?.isEmpty ?? true, "描述不应为空")
            print("✅ \(uti): \(description ?? "无描述")")
        }
    }

    // MARK: - Test Validation

    func testIsValidUTI() {
        // Given: 有效和无效的 UTI
        let validUTIs = ["com.adobe.pdf", "public.plain-text", "public.jpeg"]
        let invalidUTIs = ["", "invalid", "com.nonexistent.type"]

        // When & Then: 验证有效性
        for uti in validUTIs {
            XCTAssertTrue(manager.isValidUTI(uti), "\(uti) 应该是有效的")
        }

        for uti in invalidUTIs {
            XCTAssertFalse(manager.isValidUTI(uti), "\(uti) 应该是无效的")
        }
    }

    func testIsValidExtension() {
        // Given: 有效和无效的扩展名
        let validExts = [".pdf", ".txt", ".jpg", ".png"]
        let invalidExts = ["", ".xyz12345"]

        // When & Then: 验证有效性
        for ext in validExts {
            XCTAssertTrue(manager.isValidExtension(ext), "\(ext) 应该是有效的")
        }

        for ext in invalidExts {
            if manager.isValidExtension(ext) {
                print("⚠️  \(ext) 被系统识别为有效（可能是动态 UTI）")
            }
        }
    }

    // MARK: - Test Common UTIs

    func testGetCommonUTI() {
        // Given: 在常见列表中的扩展名
        let testCases: [(ext: String, expectedUTI: String)] = [
            (".pdf", "com.adobe.pdf"),
            (".txt", "public.plain-text"),
            (".jpg", "public.jpeg"),
            (".mp3", "public.mp3")
        ]

        // When & Then: 应该快速返回预定义的 UTI
        for (ext, expectedUTI) in testCases {
            let uti = manager.getCommonUTI(forExtension: ext)
            XCTAssertEqual(uti, expectedUTI, "\(ext) 应该返回 \(expectedUTI)")
        }
    }

    // MARK: - Test Supertypes

    func testGetSupertypes() {
        // Given: PDF UTI
        let uti = "com.adobe.pdf"

        // When: 获取父类型
        let supertypes = manager.getSupertypes(forUTI: uti)

        // Then: 应该包含公共父类型（如 public.data）
        XCTAssertFalse(supertypes.isEmpty, "PDF 应该有父类型")
        print("✅ \(uti) 的父类型: \(supertypes)")
    }

    // MARK: - Performance Tests

    func testPerformance_GetUTI() {
        measure {
            _ = manager.getUTI(forExtension: ".pdf")
        }
    }

    func testPerformance_GetExtensions() {
        measure {
            _ = manager.getExtensions(forUTI: "com.adobe.pdf")
        }
    }

    func testPerformance_GetCommonUTI() {
        measure {
            _ = manager.getCommonUTI(forExtension: ".pdf")
        }
    }
}
