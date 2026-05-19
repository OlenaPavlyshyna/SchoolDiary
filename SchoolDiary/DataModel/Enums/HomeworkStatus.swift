//
//  HomeworkStatus.swift
//  SchoolDiary
//
//  Created by Olena Pavlyshyna on 18.05.2026.
//

import Foundation

enum HomeworkStatus: String, CaseIterable, Codable, Hashable, Identifiable {
    case active
    case completed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .active:
            return "Активне"
        case .completed:
            return "Виконане"
        }
    }

    var systemImage: String {
        switch self {
        case .active:
            return "circle"
        case .completed:
            return "checkmark.circle.fill"
        }
    }
}
