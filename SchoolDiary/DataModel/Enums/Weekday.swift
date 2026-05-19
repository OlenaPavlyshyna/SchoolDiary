import Foundation

enum Weekday: Int, CaseIterable, Codable, Hashable, Identifiable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .monday:
            return "Понеділок"
        case .tuesday:
            return "Вівторок"
        case .wednesday:
            return "Середа"
        case .thursday:
            return "Четвер"
        case .friday:
            return "Пʼятниця"
        }
    }

    var shortTitle: String {
        switch self {
        case .monday:
            return "Пн"
        case .tuesday:
            return "Вт"
        case .wednesday:
            return "Ср"
        case .thursday:
            return "Чт"
        case .friday:
            return "Пт"
        }
    }

    static var currentSchoolDay: Weekday {
        let calendarWeekday = Calendar.current.component(.weekday, from: Date())

        switch calendarWeekday {
        case 2:
            return .monday
        case 3:
            return .tuesday
        case 4:
            return .wednesday
        case 5:
            return .thursday
        case 6:
            return .friday
        default:
            return .monday
        }
    }
}
