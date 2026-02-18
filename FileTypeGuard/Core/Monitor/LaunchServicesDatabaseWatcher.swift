import Foundation

/// Launch Services 数据库文件监控器
/// 监控 ~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist 的变化
final class LaunchServicesDatabaseWatcher {

    // MARK: - Properties

    private var fileDescriptor: Int32 = -1
    private var dispatchSource: DispatchSourceFileSystemObject?
    private let queue = DispatchQueue(label: "com.filetypeprotector.lsdatabase.watcher")

    /// 数据库文件路径
    private var databaseURL: URL? {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        return homeDir
            .appendingPathComponent("Library")
            .appendingPathComponent("Preferences")
            .appendingPathComponent("com.apple.LaunchServices")
            .appendingPathComponent("com.apple.launchservices.secure.plist")
    }

    /// 文件变化回调
    var onChange: (() -> Void)?

    // MARK: - Lifecycle

    deinit {
        stopWatching()
    }

    // MARK: - Public Methods

    /// 开始监控
    func startWatching() {
        guard let url = databaseURL else {
            print("❌ 无法获取 Launch Services 数据库路径")
            return
        }

        // 检查文件是否存在
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("⚠️  Launch Services 数据库文件不存在: \(url.path)")
            // 尝试监控父目录
            startWatchingParentDirectory()
            return
        }

        // 打开文件描述符
        fileDescriptor = open(url.path, O_EVTONLY)

        guard fileDescriptor >= 0 else {
            print("❌ 无法打开文件描述符: \(url.path)")
            return
        }

        // 创建 DispatchSource 监听文件写入和删除事件
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .delete, .rename],
            queue: queue
        )

        source.setEventHandler { [weak self] in
            guard let self = self else { return }
            print("📝 检测到 Launch Services 数据库变化")
            DispatchQueue.main.async {
                self.onChange?()
            }
        }

        source.setCancelHandler { [weak self] in
            guard let self = self else { return }
            if self.fileDescriptor >= 0 {
                close(self.fileDescriptor)
                self.fileDescriptor = -1
            }
        }

        source.resume()
        dispatchSource = source

        print("✅ Launch Services 数据库监控已启动: \(url.path)")
    }

    /// 停止监控
    func stopWatching() {
        dispatchSource?.cancel()
        dispatchSource = nil

        if fileDescriptor >= 0 {
            close(fileDescriptor)
            fileDescriptor = -1
        }

        print("✅ Launch Services 数据库监控已停止")
    }

    // MARK: - Private Methods

    /// 监控父目录（当数据库文件不存在时的备选方案）
    private func startWatchingParentDirectory() {
        guard let url = databaseURL?.deletingLastPathComponent() else { return }

        guard FileManager.default.fileExists(atPath: url.path) else {
            print("❌ Launch Services 目录不存在: \(url.path)")
            return
        }

        fileDescriptor = open(url.path, O_EVTONLY)

        guard fileDescriptor >= 0 else {
            print("❌ 无法打开目录描述符: \(url.path)")
            return
        }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write],
            queue: queue
        )

        source.setEventHandler { [weak self] in
            guard let self = self else { return }
            print("📝 检测到 Launch Services 目录变化")
            DispatchQueue.main.async {
                self.onChange?()
            }
        }

        source.setCancelHandler { [weak self] in
            guard let self = self else { return }
            if self.fileDescriptor >= 0 {
                close(self.fileDescriptor)
                self.fileDescriptor = -1
            }
        }

        source.resume()
        dispatchSource = source

        print("✅ Launch Services 目录监控已启动: \(url.path)")
    }
}
