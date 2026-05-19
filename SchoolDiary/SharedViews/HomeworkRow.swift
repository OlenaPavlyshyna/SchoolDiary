//
//  HomeworkRow.swift
//  SchoolDiary
//
//  Created by Olena Pavlyshyna on 18.05.2026.
//

import SwiftUI

struct HomeworkRow: View {
    let homework: Homework

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            SubjectColorDot(hex: homework.displayColorHex, size: 16)
                .padding(.top, 3)

            VStack(alignment: .leading, spacing: 6) {
                Text(homework.displaySubjectName)
                    .font(.headline)

                Text(homework.taskDescription)
                    .font(.body)
                    .foregroundStyle(.primary)

                HStack(spacing: 12) {
                    if let dueDate = homework.dueDate {
                        Label(dueDate.schoolDiaryShortDate, systemImage: "calendar")
                    } else {
                        Label("Без терміну", systemImage: "calendar.badge.questionmark")
                    }

                    HomeworkStatusLabel(homework: homework)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

