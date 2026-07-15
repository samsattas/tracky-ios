import SwiftUI

struct BankBadgeView: View {
    let bank: BankId
    var size: CGFloat = 36

    var body: some View {
        let meta = bank.meta
        let fontSize = size * 0.36

        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28)
                .fill(meta.swiftColor)
            Text(meta.short)
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(meta.swiftFg)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 8) {
        BankBadgeView(bank: .bogota,      size: 36)
        BankBadgeView(bank: .bancolombia, size: 36)
        BankBadgeView(bank: .nequi,       size: 36)
        BankBadgeView(bank: .davivienda,  size: 36)
    }
    .padding()
}
