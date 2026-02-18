import XCTest
@testable import FileTypeGuard

final class ApplicationResolverTests: XCTestCase {

    var resolver: ApplicationResolver!

    override func setUp() {
        super.setUp()
        resolver = ApplicationResolver.shared
    }

    override func tearDown() {
        resolver = nil
        super.tearDown()
    }

    // MARK: - Test resolveApplication

    func testResolveApplication_Preview() {
        // Given: Preview.app 的 Bundle ID
        let bundleID = "com.apple.Preview"

        // When: 解析应用信息
        let appInfo = resolver.resolveApplication(bundleID: bundleID)

        // Then: 应该返回有效的应用信息
        XCTAssertNotNil(appInfo, "Preview 应该被找到")
        XCTAssertEqual(appInfo?.bundleID, bundleID)
        XCTAssertEqual(appInfo?.name, "Preview", "应用名称应该是 Preview")
        XCTAssertNotNil(appInfo?.path, "应该有有效的路径")
        XCTAssertTrue(appInfo?.path.path.hasSuffix(".app") ?? false, "路径应该以 .app 结尾")

        if let appInfo = appInfo {
            print("✅ Preview 应用信息:")
            print("   名称: \(appInfo.name)")
            print("   Bundle ID: \(appInfo.bundleID)")
            print("   路径: \(appInfo.path.path)")
            print("   版本: \(appInfo.version ?? "未知")")
            print("   图标: \(appInfo.icon != nil ? "有" : "无")")
        }
    }

    func testResolveApplication_CommonApps() {
        // Given: 常见的系统应用
        let commonApps = [
            "com.apple.TextEdit",
            "com.apple.Safari",
            "com.apple.finder",
            "com.apple.systempreferences"
        ]

        // When & Then: 每个应用都应该被找到
        for bundleID in commonApps {
            let appInfo = resolver.resolveApplication(bundleID: bundleID)
            XCTAssertNotNil(appInfo, "\(bundleID) 应该被找到")
            XCTAssertEqual(appInfo?.bundleID, bundleID)
            XCTAssertFalse(appInfo?.name.isEmpty ?? true, "应用名称不应为空")

            if let appInfo = appInfo {
                print("✅ \(appInfo.name) (\(bundleID))")
            }
        }
    }

    func testResolveApplication_EmptyBundleID() {
        // Given: 空 Bundle ID
        let empty = ""

        // When: 解析应用信息
        let appInfo = resolver.resolveApplication(bundleID: empty)

        // Then: 应该返回 nil
        XCTAssertNil(appInfo, "空 Bundle ID 应该返回 nil")
    }

    func testResolveApplication_NonExistent() {
        // Given: 不存在的 Bundle ID
        let nonExistent = "com.nonexistent.application"

        // When: 解析应用信息
        let appInfo = resolver.resolveApplication(bundleID: nonExistent)

        // Then: 应该返回 nil
        XCTAssertNil(appInfo, "不存在的应用应该返回 nil")
    }

    // MARK: - Test resolveApplications (batch)

    func testResolveApplications_Batch() {
        // Given: 多个 Bundle ID（包含存在和不存在的）
        let bundleIDs = [
            "com.apple.Preview",
            "com.apple.TextEdit",
            "com.nonexistent.app",
            "com.apple.Safari"
        ]

        // When: 批量解析
        let appInfos = resolver.resolveApplications(bundleIDs: bundleIDs)

        // Then: 应该只返回存在的应用（3 个）
        XCTAssertEqual(appInfos.count, 3, "应该返回 3 个存在的应用")

        for appInfo in appInfos {
            print("✅ \(appInfo.name) (\(appInfo.bundleID))")
        }
    }

    // MARK: - Test isApplicationInstalled

    func testIsApplicationInstalled_Preview() {
        // Given: Preview.app 的 Bundle ID
        let bundleID = "com.apple.Preview"

        // When: 检查是否已安装
        let isInstalled = resolver.isApplicationInstalled(bundleID: bundleID)

        // Then: 应该返回 true
        XCTAssertTrue(isInstalled, "Preview 应该已安装")
    }

    func testIsApplicationInstalled_NonExistent() {
        // Given: 不存在的 Bundle ID
        let bundleID = "com.nonexistent.application"

        // When: 检查是否已安装
        let isInstalled = resolver.isApplicationInstalled(bundleID: bundleID)

        // Then: 应该返回 false
        XCTAssertFalse(isInstalled, "不存在的应用应该返回 false")
    }

    func testIsApplicationInstalled_EmptyBundleID() {
        // Given: 空 Bundle ID
        let empty = ""

        // When: 检查是否已安装
        let isInstalled = resolver.isApplicationInstalled(bundleID: empty)

        // Then: 应该返回 false
        XCTAssertFalse(isInstalled, "空 Bundle ID 应该返回 false")
    }

    // MARK: - Test getApplicationPath

    func testGetApplicationPath() {
        // Given: Preview.app 的 Bundle ID
        let bundleID = "com.apple.Preview"

        // When: 获取应用路径
        let path = resolver.getApplicationPath(bundleID: bundleID)

        // Then: 应该返回有效路径
        XCTAssertNotNil(path, "应该返回有效路径")
        XCTAssertTrue(path?.path.contains("Preview.app") ?? false, "路径应该包含 Preview.app")
        print("✅ Preview 路径: \(path?.path ?? "nil")")
    }

    // MARK: - Test getApplicationIcon

    func testGetApplicationIcon() {
        // Given: Preview.app 的 Bundle ID
        let bundleID = "com.apple.Preview"

        // When: 获取应用图标
        let icon = resolver.getApplicationIcon(bundleID: bundleID)

        // Then: 应该返回有效图标
        XCTAssertNotNil(icon, "应该返回有效图标")
        XCTAssertTrue(icon?.isValid ?? false, "图标应该有效")

        if let icon = icon {
            print("✅ Preview 图标大小: \(icon.size)")
        }
    }

    // MARK: - Test ApplicationInfo properties

    func testApplicationInfo_Properties() {
        // Given: 解析 Preview 应用
        guard let appInfo = resolver.resolveApplication(bundleID: "com.apple.Preview") else {
            XCTFail("应该能解析 Preview")
            return
        }

        // Then: 验证各个属性
        XCTAssertFalse(appInfo.name.isEmpty, "名称不应为空")
        XCTAssertFalse(appInfo.bundleID.isEmpty, "Bundle ID 不应为空")
        XCTAssertFalse(appInfo.pathString.isEmpty, "路径不应为空")
        XCTAssertFalse(appInfo.fullDescription.isEmpty, "完整描述不应为空")
        XCTAssertFalse(appInfo.description.isEmpty, "描述不应为空")

        print("✅ 完整描述: \(appInfo.fullDescription)")
        print("✅ 简短描述: \(appInfo.description)")
    }

    func testApplicationInfo_Equatable() {
        // Given: 两个相同的应用信息
        let appInfo1 = resolver.resolveApplication(bundleID: "com.apple.Preview")
        let appInfo2 = resolver.resolveApplication(bundleID: "com.apple.Preview")

        // Then: 应该相等
        XCTAssertEqual(appInfo1, appInfo2, "相同的应用信息应该相等")
    }

    func testApplicationInfo_Hashable() {
        // Given: 应用信息
        guard let appInfo = resolver.resolveApplication(bundleID: "com.apple.Preview") else {
            XCTFail("应该能解析 Preview")
            return
        }

        // When: 使用 Set 存储
        let set: Set = [appInfo]

        // Then: 应该能存储和检索
        XCTAssertTrue(set.contains(appInfo), "应该能在 Set 中找到")
    }

    // MARK: - Performance Tests

    func testPerformance_ResolveApplication() {
        let bundleID = "com.apple.Preview"

        measure {
            _ = resolver.resolveApplication(bundleID: bundleID)
        }
    }

    func testPerformance_IsApplicationInstalled() {
        let bundleID = "com.apple.Preview"

        measure {
            _ = resolver.isApplicationInstalled(bundleID: bundleID)
        }
    }

    func testPerformance_GetApplicationIcon() {
        let bundleID = "com.apple.Preview"

        measure {
            _ = resolver.getApplicationIcon(bundleID: bundleID)
        }
    }
}
