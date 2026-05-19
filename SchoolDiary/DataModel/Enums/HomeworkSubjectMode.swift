//
//  HomeworkSubjectMode.swift
//  SchoolDiary
//
//  Created by Olena Pavlyshyna on 18.05.2026.
//

import Foundation

enum HomeworkSubjectMode: String, CaseIterable, Identifiable {
    case existing
    case new

    var id: String { rawValue }

    var title: String {
        switch self {
        case .existing:
            return "Зі списку"
        case .new:
            return "Новий"
        }
    }
}
