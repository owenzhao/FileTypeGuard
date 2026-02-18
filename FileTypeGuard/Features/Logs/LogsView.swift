import SwiftUI

/// 日志查看页面
struct LogsView: View {

    // MARK: - State

    @StateObject private var viewModel = LogsViewModel()
    @State private var selectedLog: LogEntry?
    @State private var showingFilter = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // 工具栏
            toolbar

            Divider()

            // 搜索和筛选栏
            searchBar

            Divider()

            // 日志列表
            if viewModel.filteredLogs.isEmpty {
                emptyState
            } else {
                logsList
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
        .onAppear {
            viewModel.loadLogs()
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("log_records")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(String(localized: "\(viewModel.filteredLogs.count) records"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // 统计信息
            statisticsView

            Button {
                viewModel.loadLogs()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.plain)
            .help(String(localized: "refresh_logs"))

            Button {
                showingFilter.toggle()
            } label: {
                Image(systemName: showingFilter ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
            }
            .buttonStyle(.plain)
            .help(String(localized: "filter"))
        }
        .padding()
    }

    // MARK: - Statistics View

    private var statisticsView: some View {
        HStack(spacing: 16) {
            StatBadge(
                title: String(localized: "success"),
                count: viewModel.statistics.restoredCount,
                color: .green
            )

            StatBadge(
                title: String(localized: "failed"),
                count: viewModel.statistics.failedCount,
                color: .red
            )
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        VStack(spacing: 12) {
            // 搜索框
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField(String(localized: "search_app_or_filetype"), text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .frame(height: 20)

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(6)

            // 筛选选项（展开时显示）
            if showingFilter {
                filterOptions
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    // MARK: - Filter Options

    private var filterOptions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("filter_criteria")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                // 事件类型筛选
                Picker(String(localized: "event_type"), selection: $viewModel.selectedEventType) {
                    Text("all").tag(nil as LogEntry.EventType?)
                    ForEach([LogEntry.EventType.detected, .restored, .restoreFailed], id: \.self) { type in
                        Text(type.displayName).tag(type as LogEntry.EventType?)
                    }
                }
                .pickerStyle(.menu)

                Spacer()

                // 清除筛选
                Button(String(localized: "clear_filter")) {
                    viewModel.clearFilter()
                    showingFilter = false
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(12)
        .background(Color(nsColor: .separatorColor).opacity(0.1))
        .cornerRadius(8)
    }

    // MARK: - Logs List

    private var logsList: some View {
        List(selection: $selectedLog) {
            ForEach(viewModel.filteredLogs) { log in
                LogEntryRow(entry: log)
                    .tag(log)
            }
        }
        .listStyle(.inset)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("no_log_records")
                .font(.title2)
                .fontWeight(.semibold)

            Text("log_empty_description")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

// MARK: - Log Entry Row

struct LogEntryRow: View {
    let entry: LogEntry

    var body: some View {
        HStack(spacing: 12) {
            // 事件图标
            Image(systemName: entry.eventType.icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 32)

            // 日志信息
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.description)
                    .font(.body)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    Text(entry.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("•")
                        .foregroundStyle(.tertiary)

                    Text(entry.eventType.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // 状态标签
            if entry.status == .failed {
                Text("failed")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 8)
    }

    private var iconColor: Color {
        switch entry.eventType {
        case .detected:
            return .orange
        case .restored:
            return .green
        case .restoreFailed:
            return .red
        case .userModified:
            return .blue
        }
    }
}

// MARK: - Stat Badge

struct StatBadge: View {
    let title: String
    let count: Int
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text("\(count)")
                .font(.system(.body, design: .rounded))
                .fontWeight(.semibold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - ViewModel

@MainActor
final class LogsViewModel: ObservableObject {
    @Published var logs: [LogEntry] = []
    @Published var searchText = ""
    @Published var selectedEventType: LogEntry.EventType?
    @Published var statistics = LogStatistics(totalCount: 0, restoredCount: 0, failedCount: 0)

    private let logStore = LogStore.shared

    var filteredLogs: [LogEntry] {
        var result = logs

        // 搜索过滤
        if !searchText.isEmpty {
            result = result.filter { entry in
                entry.fileTypeName.localizedCaseInsensitiveContains(searchText) ||
                entry.fromAppName?.localizedCaseInsensitiveContains(searchText) == true ||
                entry.toAppName.localizedCaseInsensitiveContains(searchText)
            }
        }

        // 事件类型过滤
        if let eventType = selectedEventType {
            result = result.filter { $0.eventType == eventType }
        }

        return result
    }

    func loadLogs() {
        logs = logStore.getLogs(limit: 500)
        statistics = logStore.getStatistics()
        print("✅ 加载了 \(logs.count) 条日志")
    }

    func clearFilter() {
        searchText = ""
        selectedEventType = nil
    }
}

// MARK: - Preview

#Preview {
    LogsView()
        .frame(width: 700, height: 500)
}
