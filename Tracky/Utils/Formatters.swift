import Foundation

// MARK: - Currency

func fmtCOP(_ value: Double) -> String {
    let abs = Int(Swift.abs(value).rounded())
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "es_CO")
    formatter.groupingSeparator = "."
    let formatted = formatter.string(from: NSNumber(value: abs)) ?? "\(abs)"
    return "$ \(formatted)"
}

func fmtCOPSigned(_ value: Double) -> String {
    let prefix = value >= 0 ? "+ " : "− "
    return prefix + fmtCOP(value)
}

// MARK: - Date

private let MONTHS_SHORT = ["ene","feb","mar","abr","may","jun","jul","ago","sep","oct","nov","dic"]
private let MONTHS_ES    = ["Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"]

func fmtDate(_ iso: String) -> String {
    let parts = iso.split(separator: "-")
    guard parts.count >= 3,
          let day = Int(parts[2]),
          let month = Int(parts[1]) else { return iso }
    let idx = month - 1
    guard idx >= 0 && idx < MONTHS_SHORT.count else { return iso }
    return "\(day) \(MONTHS_SHORT[idx])"
}

func fmtMonthYear(_ date: Date) -> String {
    let cal = Calendar.current
    let month = cal.component(.month, from: date) - 1
    let year  = cal.component(.year, from: date)
    return "\(MONTHS_ES[month]) \(year)"
}

func currentMonthKey() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM"
    return formatter.string(from: Date())
}

func monthKey(offsetBy months: Int, from date: Date = Date()) -> String {
    var comps = DateComponents()
    comps.month = months
    let d = Calendar.current.date(byAdding: comps, to: date) ?? date
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM"
    return formatter.string(from: d)
}

func monthShort(offsetBy months: Int, from date: Date = Date()) -> String {
    var comps = DateComponents()
    comps.month = months
    let d = Calendar.current.date(byAdding: comps, to: date) ?? date
    let idx = Calendar.current.component(.month, from: d) - 1
    return MONTHS_SHORT[max(0, min(11, idx))]
}
