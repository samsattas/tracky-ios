import SwiftUI

struct DonutSegment {
    let value: Double
    let color: Color
}

struct DonutChartView: View {
    let segments: [DonutSegment]
    var size: CGFloat = 140
    var centerLabel: String = ""

    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    private var total: Double { segments.reduce(0) { $0 + $1.value } }

    var body: some View {
        ZStack {
            Canvas { ctx, sz in
                let cx = sz.width / 2
                let cy = sz.height / 2
                let r = min(cx, cy)
                let inner = r * 0.58
                var startAngle = -Double.pi / 2
                let gap: Double = segments.count > 1 ? 0.02 : 0

                for seg in segments {
                    guard total > 0 else { continue }
                    let sweep = (seg.value / total) * (2 * .pi) - gap
                    let path = donutArc(cx: cx, cy: cy, outerR: r, innerR: inner, start: startAngle, end: startAngle + sweep)
                    ctx.fill(path, with: .color(seg.color))
                    startAngle += sweep + gap
                }
            }
            .frame(width: size, height: size)

            VStack(spacing: 2) {
                Text(centerLabel)
                    .font(.system(size: size * 0.12, weight: .bold))
                    .foregroundColor(C.text)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.horizontal, size * 0.1)
            }
        }
        .frame(width: size, height: size)
    }

    private func donutArc(cx: CGFloat, cy: CGFloat, outerR: CGFloat, innerR: CGFloat, start: Double, end: Double) -> Path {
        var path = Path()
        let outerStart = CGPoint(x: cx + outerR * cos(start), y: cy + outerR * sin(start))
        path.move(to: outerStart)
        path.addArc(center: CGPoint(x: cx, y: cy), radius: outerR, startAngle: .radians(start), endAngle: .radians(end), clockwise: false)
        let innerEnd = CGPoint(x: cx + innerR * cos(end), y: cy + innerR * sin(end))
        path.addLine(to: innerEnd)
        path.addArc(center: CGPoint(x: cx, y: cy), radius: innerR, startAngle: .radians(end), endAngle: .radians(start), clockwise: true)
        path.closeSubpath()
        return path
    }
}
