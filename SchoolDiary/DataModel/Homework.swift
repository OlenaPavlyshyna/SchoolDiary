//
//  Homework.swift
//  SchoolDiary
//
//  Created by Olena Pavlyshyna on 18.05.2026.
//

import Foundation
import SwiftData

@Model
final class Homework {
    var taskDescription: String
    var createdAt: Date
    var dueDate: Date?
    var statusRawValue: String
    var subjectName: String
    var subjectColorHex: String
    var subject: Subject?

    init(
        subject: Subject?,
        subjectName: String,
        subjectColorHex: String,
        taskDescription: String,
        createdAt: Date = Date(),
        dueDate: Date? = nil,
        status: HomeworkStatus = .active
    ) {
        self.subject = subject
        self.subjectName = subjectName
        self.subjectColorHex = subjectColorHex
        self.taskDescription = taskDescription
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.statusRawValue = status.rawValue
    }

    var status: HomeworkStatus {
        get { HomeworkStatus(rawValue: statusRawValue) ?? .active }
        set { statusRawValue = newValue.rawValue }
    }

    var displaySubjectName: String {
        subject?.name ?? subjectName
    }

    var displayColorHex: String {
        subject?.colorHex ?? subjectColorHex
    }

    var sectionKind: HomeworkSectionKind {
        if status == .completed {
            return .completed
        }

        guard let dueDate else {
            return .noDueDate
        }

        let startOfToday = Calendar.current.startOfDay(for: Date())
        let dueDay = Calendar.current.startOfDay(for: dueDate)
        return dueDay < startOfToday ? .overdue : .active
    }

    var isRecent: Bool {
        let referenceDate = dueDate ?? createdAt
        guard let threshold = Calendar.current.date(byAdding: .day, value: -14, to: Date()) else {
            return true
        }
        return referenceDate >= threshold
    }
}

