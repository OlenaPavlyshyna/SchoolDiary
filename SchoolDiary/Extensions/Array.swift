//
//  Array.swift
//  SchoolDiary
//
//  Created by Olena Pavlyshyna on 18.05.2026.
//

extension Array where Element == Homework {
    func sortedByHomeworkPriority() -> [Homework] {
        sorted { first, second in
            if first.sectionKind.rawValue != second.sectionKind.rawValue {
                return first.sectionKind.sortOrder < second.sectionKind.sortOrder
            }

            switch (first.dueDate, second.dueDate) {
            case let (firstDate?, secondDate?):
                return firstDate < secondDate
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                return first.createdAt > second.createdAt
            }
        }
    }
}
