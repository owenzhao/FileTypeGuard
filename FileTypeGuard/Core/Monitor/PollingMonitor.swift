import Foundation

/// 轮询监控器
/// 定期检查所有保护类型的文件关联是否符合预期
final class PollingMonitor {

    // MARK: - Properties

    private var timer: Timer?
    private let interval: TimeInterval

    /// 检查回调
    var onCheck: (() -> Void)?

    // MARK: - Initialization

    init(interval: TimeInterval = 30.0) {
        self.interval = interval
    }

    deinit {
        stopPolling()
    }

    // MARK: - Public Methods

    /// 开始轮询
    func startPolling() {
        // 停止现有定时器
        stopPolling()

        // 创建新定时器
        timer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: true
        ) { [weak self] _ in
            guard let self = self else { return }
            print("🔄 轮询监控触发检查")
            self.onCheck?()
        }

        // 确保在主线程运行
        RunLoop.main.add(timer!, forMode: .common)

        print("✅ 轮询监控已启动，间隔: \(interval) 秒")
    }

    /// 停止轮询
    func stopPolling() {
        timer?.invalidate()
        timer = nil
        print("✅ 轮询监控已停止")
    }

    /// 立即执行一次检查
    func checkNow() {
        print("🔄 手动触发检查")
        onCheck?()
    }
}
