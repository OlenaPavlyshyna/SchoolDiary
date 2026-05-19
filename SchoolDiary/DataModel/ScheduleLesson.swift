//
//  ScheduleLesson.swift
//  SchoolDiary
//
//  Created by Olena Pavlyshyna on 18.05.2026.
//

import SwiftData

@Model
final class ScheduleLesson {
    var order: Int
    var weekdayRawValue: Int
    var subjectName: String
    var subjectColorHex: String
    var subject: Subject?
    var teacher: Teacher?

    init(
        order: Int,
        weekday: Weekday,
        subject: Subject?,
        subjectName: String,
        subjectColorHex: String,
        teacher: Teacher? = nil
    ) {
        self.order = order
        self.weekdayRawValue = weekday.rawValue
        self.subject = subject
        self.subjectName = subjectName
        self.subjectColorHex = subjectColorHex
        self.teacher = teacher
    }

    var weekday: Weekday {
        get { Weekday(rawValue: weekdayRawValue) ?? .monday }
        set { weekdayRawValue = newValue.rawValue }
    }

    var displaySubjectName: String {
        subject?.name ?? subjectName
    }

    var displayColorHex: String {
        subject?.colorHex ?? subjectColorHex
    }
}
