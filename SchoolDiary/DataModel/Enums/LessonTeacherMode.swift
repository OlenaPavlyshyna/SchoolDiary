//
//  LessonTeacherMode.swift
//  SchoolDiary
//
//  Created by Olena Pavlyshyna on 18.05.2026.
//

enum LessonTeacherMode: String, CaseIterable, Identifiable {
    case none
    case existing
    case new

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none:
            return "Без вчителя"
        case .existing:
            return "Зі списку"
        case .new:
            return "Новий"
        }
    }
}
