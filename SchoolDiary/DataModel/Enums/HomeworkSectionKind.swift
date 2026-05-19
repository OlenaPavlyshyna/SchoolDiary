enum HomeworkSectionKind: String, CaseIterable, Identifiable {
    case active
    case overdue
    case noDueDate
    case completed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .active:
            return "Активні"
        case .overdue:
            return "Прострочені"
        case .noDueDate:
            return "Без терміну виконання"
        case .completed:
            return "Виконані"
        }
    }

    var systemImage: String {
        switch self {
        case .active:
            return "calendar.badge.clock"
        case .overdue:
            return "exclamationmark.triangle.fill"
        case .noDueDate:
            return "calendar.badge.questionmark"
        case .completed:
            return "checkmark.circle.fill"
        }
    }

    var sortOrder: Int {
        switch self {
        case .active:
            return 0
        case .overdue:
            return 1
        case .noDueDate:
            return 2
        case .completed:
            return 3
        }
    }
}
