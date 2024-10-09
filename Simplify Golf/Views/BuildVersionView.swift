import SwiftUI

struct BuildVersionView: View {
    var body: some View {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        {
            Text("v\(version) (\(build))")
                .font(.system(size: 10))
                .foregroundColor(.gray.opacity(0.7))
                .padding(4)
        }
    }
}
