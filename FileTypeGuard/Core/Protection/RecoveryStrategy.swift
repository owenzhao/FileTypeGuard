import Foundation

/// 恢复策略
enum RecoveryStrategy: String, Codable {
    case immediate      // 立即恢复
    case delayed        // 延迟恢复（给用户反悔时间）
    case askUser        // 询问用户

    var description: String {
        switch self {
        case .immediate:
            return "立即恢复"
        case .delayed:
            return "延迟恢复"
        case .askUser:
            return "询问用户"
        }
    }

    var delaySeconds: TimeInterval {
        switch self {
        case .immediate:
            return 0.0
        case .delayed:
            return 5.0
        case .askUser:
            return 0.0  // 询问模式不使用延迟
        }
    }
}
