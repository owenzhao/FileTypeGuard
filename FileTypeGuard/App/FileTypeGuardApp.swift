import SwiftUI
import AppKit

@main
struct FileTypeGuardApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appCoordinator)
        }
        .defaultSize(width: 900, height: 600)
        .commands {
            // 删除默认的"新建窗口"菜单项
            CommandGroup(replacing: .newItem) { }
        }
    }
}

/// 应用代理
/// 负责设置菜单栏图标和处理窗口关闭
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    private var statusItem: NSStatusItem?
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 创建菜单栏图标
        setupStatusItem()

        // 确保首次启动时窗口在最前
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func applicationWillFinishLaunching(_ notification: Notification) {
        // 注册通知监听
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWindowClose),
            name: .simulatedWindowClose,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUpdateWindow(_:)),
            name: .updateWindow,
            object: nil
        )
    }

    @objc private func handleUpdateWindow(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: NSWindow], let window = userInfo["window"] {
            self.window = window
        }
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            let config = NSImage.SymbolConfiguration(pointSize: 18, weight: .regular)
            button.image = NSImage(systemSymbolName: "lock.shield.fill", accessibilityDescription: "FileTypeGuard")?.withSymbolConfiguration(config)
            button.image?.isTemplate = true
            button.action = #selector(toggleMainWindow)
            button.target = self
        }
    }

    /// 窗口即将关闭时，阻止关闭并隐藏应用
    @objc private func handleWindowClose(_ notification: Notification) {
        NSApp.hide(nil)
        NSApp.setActivationPolicy(.accessory)  // 隐藏 Dock 图标
    }

    /// 切换窗口显示/隐藏
    @objc private func toggleMainWindow() {
        if NSApp.isHidden || NSApp.activationPolicy() == .accessory {
            // 如果应用隐藏或 Dock 图标不显示，则恢复
            NSApp.setActivationPolicy(.regular)  // 显示 Dock 图标
            NSApp.unhide(nil)

            if let window = window {
                window.makeKeyAndOrderFront(nil)
            } else if let mainWindow = NSApp.windows.first {
                window = mainWindow
                window?.delegate = self
                mainWindow.makeKeyAndOrderFront(nil)
            }
            NSApp.activate(ignoringOtherApps: true)
        } else {
            // 如果应用显示，则隐藏
            NSApp.hide(nil)
        }
    }

    /// 阻止应用在窗口关闭时退出
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

/// 窗口代理
/// 用于捕获窗口关闭事件
class WindowDelegate: NSObject, NSWindowDelegate {
    static let shared = WindowDelegate()

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NotificationCenter.default.post(name: .simulatedWindowClose, object: sender)
        return false  // 阻止窗口关闭
    }
}

/// 扩展 Notification.Name
extension Notification.Name {
    static let simulatedWindowClose = Notification.Name("simulatedWindowClose")
    static let updateWindow = Notification.Name("updateWindow")
}

/// 应用协调器
/// 负责管理监控和保护引擎的生命周期
@MainActor
final class AppCoordinator: ObservableObject {

    // MARK: - Properties

    private let monitor: FileAssociationMonitor
    private let protectionEngine: ProtectionEngine
    private let notificationService = NotificationService.shared
    private let configManager = ConfigurationManager.shared

    @Published var isMonitoring = false
    @Published var lastCheckTime: Date?

    // MARK: - Initialization

    init() {
        // 获取用户配置的轮询间隔
        let preferences = configManager.getPreferences()
        let interval = preferences.checkInterval

        // 初始化监控器和保护引擎
        self.monitor = FileAssociationMonitor(pollingInterval: interval)
        self.protectionEngine = ProtectionEngine()

        // 设置回调
        setupCallbacks()

        // 请求通知权限
        Task {
            await notificationService.requestAuthorization()
        }

        // 如果配置了自动启动监控，则启动
        if preferences.monitoringEnabled {
            startMonitoring()
        }
    }

    // MARK: - Public Methods

    /// 启动监控
    func startMonitoring() {
        guard !isMonitoring else { return }

        monitor.startMonitoring()
        isMonitoring = true

        print("✅ AppCoordinator: 监控已启动")
    }

    /// 停止监控
    func stopMonitoring() {
        guard isMonitoring else { return }

        monitor.stopMonitoring()
        isMonitoring = false

        print("✅ AppCoordinator: 监控已停止")
    }

    /// 手动触发检查
    func checkNow() {
        monitor.checkNow()
    }

    // MARK: - Private Methods

    /// 设置监控和保护引擎的回调
    private func setupCallbacks() {
        // 监控器检测到变化时，触发保护引擎验证所有规则
        monitor.onDetectedChange = { [weak self] in
            guard let self = self else { return }

            Task { @MainActor in
                self.lastCheckTime = Date()
                self.protectionEngine.validateAllRules()
            }
        }

        // 保护引擎恢复成功回调
        protectionEngine.onRecoverySuccess = { [weak self] uti, oldApp, newApp in
            guard let self = self else { return }

            print("✅ 恢复成功: \(uti)")
            print("   旧应用: \(oldApp)")
            print("   新应用: \(newApp)")

            // 获取显示名称
            Task { @MainActor in
                if let rule = ConfigurationManager.shared.getProtectionRules().first(where: { $0.fileType.uti == uti }) {
                    let oldAppInfo = Application.from(bundleID: oldApp)
                    let newAppInfo = Application.from(bundleID: newApp)

                    // 发送成功通知
                    if ConfigurationManager.shared.getPreferences().showNotifications {
                        self.notificationService.send(.associationRestored(
                            fileType: uti,
                            fileTypeName: rule.fileType.displayName,
                            fromApp: oldAppInfo?.name ?? oldApp,
                            toApp: newAppInfo?.name ?? newApp
                        ))
                    }
                }
            }
        }

        // 保护引擎恢复失败回调
        protectionEngine.onRecoveryFailure = { [weak self] uti, error in
            guard let self = self else { return }

            print("❌ 恢复失败: \(uti)")
            print("   错误: \(error.localizedDescription)")

            // 获取显示名称
            Task { @MainActor in
                if let rule = ConfigurationManager.shared.getProtectionRules().first(where: { $0.fileType.uti == uti }) {
                    // 发送失败通知
                    if ConfigurationManager.shared.getPreferences().showNotifications {
                        self.notificationService.send(.recoveryFailed(
                            fileType: uti,
                            fileTypeName: rule.fileType.displayName,
                            error: error.localizedDescription
                        ))
                    }
                }
            }
        }
    }
}
