import SwiftUI

struct CategoriesView: View {
    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    @EnvironmentObject var rulesStore: RulesStore
    @State private var showNewRule = false
    private var rules: [Rule] { rulesStore.items }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppBarView(
                    title: "Categorías",
                    subtitle: "\(CATEGORIES.count) categorías · \(rules.count) reglas"
                )

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {

                        // Category grid
                        Text("CATEGORÍAS")
                            .font(.system(size: 11, weight: .bold)).foregroundColor(C.textMuted).tracking(1)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                            ForEach(Array(CATEGORIES.keys), id: \.rawValue) { catId in
                                let cat = catId.meta
                                let colors = hueToColor(cat.hue)
                                VStack(spacing: 6) {
                                    CategoryDotView(id: catId.rawValue, size: 40)
                                    Text(cat.name)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(C.text)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(colors.bg.opacity(0.6))
                                .cornerRadius(Radii.md)
                            }
                        }

                        // Rules section
                        HStack {
                            Text("REGLAS AUTOMÁTICAS")
                                .font(.system(size: 11, weight: .bold)).foregroundColor(C.textMuted).tracking(1)
                            Spacer()
                            Button(action: { showNewRule = true }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                                    .frame(width: 26, height: 26).background(C.primary).cornerRadius(13)
                            }
                        }
                        .padding(.top, 4)

                        if rules.isEmpty {
                            EmptyStateView(
                                icon: "wand.and.stars",
                                title: "Sin reglas aún",
                                subtitle: "Crea reglas para que las transacciones se categoricen automáticamente.",
                                action: "Crear primera regla",
                                onAction: { showNewRule = true },
                                accent: .primary
                            )
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(rules.enumerated()), id: \.element.id) { i, rule in
                                    ruleRow(rule, isLast: i == rules.count - 1)
                                }
                            }
                            .background(C.surface)
                            .cornerRadius(Radii.lg)
                            .overlay(RoundedRectangle(cornerRadius: Radii.lg).stroke(C.border, lineWidth: 1))
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(16)
                }
            }
            .background(C.bg.ignoresSafeArea())
            .navigationBarHidden(true)
            .task { await rulesStore.load() }
            .sheet(isPresented: $showNewRule) {
                NewRuleView(onSave: { match, category, priority in
                    Task { await rulesStore.create(match: match, category: category, priority: priority) }
                })
            }
        }
    }

    private func ruleRow(_ rule: Rule, isLast: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 14)).foregroundColor(C.primaryInk)
                .frame(width: 32, height: 32).background(C.primarySoft).cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text("\"\(rule.match)\" → \(CategoryId(rawValue: rule.category)?.meta.name ?? rule.category)")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(C.text)
                Text("Prioridad \(rule.priority)")
                    .font(.system(size: 11)).foregroundColor(C.textMuted)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { rule.enabled },
                set: { val in Task { await rulesStore.toggle(id: rule.id, enabled: val) } }
            ))
            .labelsHidden().tint(C.primary)
        }
        .padding(14)
        .overlay(alignment: .bottom) {
            if !isLast { Divider() }
        }
    }
}

struct NewRuleView: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (String, String, Int) -> Void

    @State private var match    = ""
    @State private var category = ""
    @State private var priority = 1

    var body: some View {
        NavigationStack {
            Form {
                Section("Condición") {
                    TextField("Si el comercio contiene…", text: $match)
                }
                Section("Categoría") {
                    TextField("Ej: transport, food, subs", text: $category)
                }
            }
            .navigationTitle("Nueva regla").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave(match, category, priority)
                        dismiss()
                    }
                    .disabled(match.isEmpty || category.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
