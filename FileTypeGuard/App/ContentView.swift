import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("FileTypeGuard")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("tagline")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("v0.1.0-dev")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 10)
        }
        .frame(width: 400, height: 300)
        .padding()
    }
}

#Preview {
    ContentView()
}
