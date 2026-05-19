struct SubjectPalette: Identifiable, Hashable {
    let id: String
    let name: String
    let hex: String

    static let options: [SubjectPalette] = [
        SubjectPalette(id: "blue", name: "Синій", hex: "#3B82F6"),
        SubjectPalette(id: "green", name: "Зелений", hex: "#22C55E"),
        SubjectPalette(id: "orange", name: "Помаранчевий", hex: "#F97316"),
        SubjectPalette(id: "red", name: "Червоний", hex: "#EF4444"),
        SubjectPalette(id: "purple", name: "Фіолетовий", hex: "#8B5CF6"),
        SubjectPalette(id: "teal", name: "Бірюзовий", hex: "#14B8A6"),
        SubjectPalette(id: "pink", name: "Рожевий", hex: "#EC4899"),
        SubjectPalette(id: "slate", name: "Сірий", hex: "#64748B")
    ]

    static let fallbackHex = "#3B82F6"
}
