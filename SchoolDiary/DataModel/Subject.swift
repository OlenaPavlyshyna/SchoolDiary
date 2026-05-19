//
//  Subject.swift
//  SchoolDiary
//
//  Created by Olena Pavlyshyna on 18.05.2026.
//

import SwiftData

@Model
final class Subject {
    var name: String
    var colorHex: String
    @Relationship(deleteRule: .nullify, inverse: \ScheduleLesson.subject)
    var lessons: [ScheduleLesson] = []
    @Relationship(deleteRule: .nullify, inverse: \Homework.subject)
    var homeworks: [Homework] = []

    init(name: String, colorHex: String = SubjectPalette.fallbackHex) {
        self.name = name
        self.colorHex = colorHex
    }
}
