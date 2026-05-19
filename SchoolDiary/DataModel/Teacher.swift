//
//  Teacher.swift
//  SchoolDiary
//
//  Created by Olena Pavlyshyna on 18.05.2026.
//

import SwiftData

@Model
final class Teacher {
    var name: String
    @Relationship(deleteRule: .nullify, inverse: \ScheduleLesson.teacher)
    var lessons: [ScheduleLesson] = []

    init(name: String) {
        self.name = name
    }
}
