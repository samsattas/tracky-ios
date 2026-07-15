import SwiftUI

struct AppBarView: View {
    var title: String
    var subtitle: String? = nil
    var titleView: AnyView? = nil
    var leading: AnyView? = nil
    var trailing: AnyView? = nil
    var large: Bool = false

    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    var body: some View {
        HStack(alignment: large ? .top : .center, spacing: 10) {
            if let leading { leading }

            VStack(alignment: .leading, spacing: 2) {
                if let tv = titleView {
                    tv
                } else {
                    Text(title)
                        .font(.system(size: large ? 24 : 16, weight: .heavy))
                        .tracking(-0.4)
                        .foregroundColor(C.text)
                }
                if let sub = subtitle {
                    Text(sub)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(C.textMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let trailing { trailing }
        }
        .padding(large ? 16 : 12)
        .padding(.horizontal, large ? 0 : 2)
        .background(C.surface)
        .overlay(alignment: .bottom) {
            if !large {
                Divider()
            }
        }
    }
}
