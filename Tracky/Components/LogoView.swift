import SwiftUI

struct LogoView: View {
    var size: CGFloat = 22

    var body: some View {
        HStack(spacing: 5) {
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.3)
                    .fill(Color(hex: "#009f89"))
                    .frame(width: size * 1.4, height: size * 1.4)
                Text("T")
                    .font(.system(size: size * 0.8, weight: .black))
                    .foregroundColor(.white)
            }
            Text("tracky")
                .font(.system(size: size, weight: .black))
                .foregroundColor(Color(hex: "#009f89"))
        }
    }
}

#Preview {
    LogoView(size: 22)
        .padding()
}
