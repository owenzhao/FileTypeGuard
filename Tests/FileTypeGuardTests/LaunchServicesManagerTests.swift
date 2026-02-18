import XCTest
@testable import FileTypeGuard

final class LaunchServicesManagerTests: XCTestCase {

    var manager: LaunchServicesManager!

    override func setUp() {
        super.setUp()
        manager = LaunchServicesManager.shared
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    // MARK: - Test getDefaultApplication

    func testGetDefaultApplication_ForPDF() throws {
        // Given: macOS 系统有 PDF 的默认应用
        let uti = "com.adobe.pdf"

        // When: 获取默认应用
        let bundleID = try manager.getDefaultApplication(for: uti)

        // Then: 返回有效的 Bundle ID
        XCTAssertNotNil(bundleID, "PDF 应该有默认应用")
        XCTAssertFalse(bundleID?.isEmpty ?? true, "Bundle ID 不应为空")

        print("✅ PDF 默认应用: \(bundleID ?? "nil")")
    }

    func testGetDefaultApplication_ForCommonTypes() throws {
        // Given: 常见的文件类型
        let commonUTIs = [
            "public.plain-text",     // .txt
            "public.jpeg",           // .jpg
            "public.png",            // .png
            "public.html"            // .html
        ]

        // When & Then: 每个类型都应该有默认应用或返回 nil（而不是抛出错误）
        for uti in commonUTIs {
            do {
                let bundleID = try manager.getDefaultApplication(for: uti)
                print("✅ \(uti): \(bundleID ?? "无默认应用")")
            } catch {
                XCTFail("获取 \(uti) 的默认应用时出错: \(error)")
            }
        }
    }

    func testGetDefaultApplication_InvalidUTI() {
        // Given: 空 UTI
        let emptyUTI = ""

        // When & Then: 应该抛出 invalidUTI 错误
        XCTAssertThrowsError(try manager.getDefaultApplication(for: emptyUTI)) { error in
            guard case LaunchServicesManager.LSError.invalidUTI = error else {
                XCTFail("应该抛出 invalidUTI 错误")
                return
            }
        }
    }

    // MARK: - Test getAvailableApplications

    func testGetAvailableApplications_ForPDF() {
        // Given: PDF 类型
        let uti = "com.adobe.pdf"

        // When: 获取可用应用列表
        let apps = manager.getAvailableApplications(for: uti)

        // Then: 应该返回至少一个应用（通常是 Preview.app）
        XCTAssertFalse(apps.isEmpty, "PDF 应该有至少一个可用应用")

        print("✅ PDF 可用应用数量: \(apps.count)")
        apps.forEach { print("  - \($0)") }
    }

    func testGetAvailableApplications_EmptyUTI() {
        // Given: 空 UTI
        let emptyUTI = ""

        // When: 获取可用应用列表
        let apps = manager.getAvailableApplications(for: emptyUTI)

        // Then: 应该返回空数组
        XCTAssertTrue(apps.isEmpty, "空 UTI 应该返回空数组")
    }

    // MARK: - Test setDefaultApplication

    func testSetDefaultApplication_RequiresPermission() {
        // 注意: 此测试需要系统权限，在 CI 环境中可能失败
        // 仅作为手动测试参考

        // Given: 一个 UTI 和应用 Bundle ID
        let uti = "public.plain-text"
        let bundleID = "com.apple.TextEdit"

        // When: 尝试设置默认应用
        // Then: 可能需要用户授权（Automation 权限）

        do {
            try manager.setDefaultApplication(bundleID, for: uti)
            print("✅ 成功设置 \(uti) 的默认应用为 \(bundleID)")

            // 验证设置
            let currentApp = try manager.getDefaultApplication(for: uti)
            XCTAssertEqual(currentApp, bundleID, "默认应用应该被设置为 \(bundleID)")
        } catch {
            // 权限问题是预期内的
            print("⚠️  设置默认应用失败（可能需要权限）: \(error)")
        }
    }

    // MARK: - Performance Tests

    func testPerformance_GetDefaultApplication() {
        let uti = "com.adobe.pdf"

        measure {
            _ = try? manager.getDefaultApplication(for: uti)
        }
    }

    func testPerformance_GetAvailableApplications() {
        let uti = "com.adobe.pdf"

        measure {
            _ = manager.getAvailableApplications(for: uti)
        }
    }
}
