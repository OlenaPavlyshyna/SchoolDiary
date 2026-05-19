import SwiftUI

struct ScheduleLessonRow: View {
    let lesson: ScheduleLesson

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: lesson.displayColorHex))
                    .frame(width: 34, height: 34)

                Text("\(lesson.order)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.displaySubjectName)
                    .font(.headline)

                if let teacherName = lesson.teacher?.name, !teacherName.isEmpty {
                    Label(teacherName, systemImage: "person")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    List {
        ScheduleLessonRow(
            lesson: ScheduleLesson(
                order: 1,
                weekday: .monday,
                subject: nil,
                subjectName: "Математика",
                subjectColorHex: "#3B82F6",
                teacher: Teacher(name: "Олена Коваль")
            )
        )
    }
}
