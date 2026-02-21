import SwiftUI
import SwiftUIWindowBinder

/// 主窗口视图
struct MainView: View {

    // MARK: - State

    @State private var selectedTab: NavigationTab = .protectedTypes
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var window: SwiftUIWindowBinder.Window?

    // MARK: - Body

    var body: some View {
        WindowBinder(window: $window) {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                // 侧边栏
                sidebar
            } detail: {
                // 内容区
                detailView
            }
            .navigationTitle("FileTypeGuard")
            .onChange(of: window) { newWindow in
                if let window = newWindow {
                    window.delegate = WindowDelegate.shared
                    NotificationCenter.default.post(name: .updateWindow, object: nil, userInfo: ["window": window])
                }
            }
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        List(NavigationTab.allCases, id: \.self, selection: $selectedTab) { tab in
            NavigationLink(value: tab) {
                Label(tab.title, systemImage: tab.icon)
            }
        }
        .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 250)
        .listStyle(.sidebar)
    }

    // MARK: - Detail View

    @ViewBuilder
    private var detailView: some View {
        switch selectedTab {
        case .protectedTypes:
            ProtectedTypesView()
        case .logs:
            LogsView()
        case .settings:
            SettingsView()
        }
    }
}

// MARK: - Navigation Tab

enum NavigationTab: String, CaseIterable {
    case protectedTypes
    case logs
    case settings

    var title: String {
        switch self {
        case .protectedTypes:
            return String(localized: "protected_types")
        case .logs:
            return String(localized: "logs")
        case .settings:
            return String(localized: "settings")
        }
    }

    var icon: String {
        switch self {
        case .protectedTypes:
            return "shield.checkered"
        case .logs:
            return "doc.text.magnifyingglass"
        case .settings:
            return "gearshape"
        }
    }
}

// MARK: - Preview

#Preview {
    MainView()
        .environmentObject(AppCoordinator())
        .frame(width: 900, height: 600)
}
