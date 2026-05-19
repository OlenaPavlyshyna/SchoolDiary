import Foundation
import SwiftData

enum SampleData {

    private static func ensureProfile(in context: ModelContext) {
        let descriptor = FetchDescriptor<DiaryProfile>()
        guard let profiles = try? context.fetch(descriptor), profiles.isEmpty else {
            return
        }

        try? context.save()
    }

    private static func dateByAdding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
    }
}


extension SampleData {
    static var preview: ModelContainer {
        let schema = Schema([
            DiaryProfile.self,
            Teacher.self,
            Subject.self,
            ScheduleLesson.self,
            Homework.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        insertSampleData(in: container.mainContext)
        return container
    }

    private static func insertSampleData(in context: ModelContext) {
        let math = Subject(name: "Математика", colorHex: "#3B82F6")
        let ukrainian = Subject(name: "Українська мова", colorHex: "#F97316")
        let history = Subject(name: "Історія", colorHex: "#8B5CF6")
        let biology = Subject(name: "Біологія", colorHex: "#22C55E")
        let english = Subject(name: "Англійська", colorHex: "#14B8A6")

        let mathTeacher = Teacher(name: "Олена Коваль")
        let ukrainianTeacher = Teacher(name: "Наталія Шевченко")
        let historyTeacher = Teacher(name: "Андрій Мельник")
        let englishTeacher = Teacher(name: "Ірина Бондар")

        [math, ukrainian, history, biology, english].forEach { context.insert($0) }
        [mathTeacher, ukrainianTeacher, historyTeacher, englishTeacher].forEach { context.insert($0) }

        let lessons = [
//            ScheduleLesson(order: 1, weekday: .monday, subject: math, subjectName: math.name, subjectColorHex: math.colorHex, teacher: mathTeacher),
//            ScheduleLesson(order: 2, weekday: .monday, subject: ukrainian, subjectName: ukrainian.name, subjectColorHex: ukrainian.colorHex, teacher: ukrainianTeacher),
//            ScheduleLesson(order: 3, weekday: .monday, subject: english, subjectName: english.name, subjectColorHex: english.colorHex, teacher: englishTeacher),
            ScheduleLesson(order: 1, weekday: .tuesday, subject: history, subjectName: history.name, subjectColorHex: history.colorHex, teacher: historyTeacher),
            ScheduleLesson(order: 2, weekday: .tuesday, subject: biology, subjectName: biology.name, subjectColorHex: biology.colorHex),
            ScheduleLesson(order: 1, weekday: .wednesday, subject: math, subjectName: math.name, subjectColorHex: math.colorHex, teacher: mathTeacher),
            ScheduleLesson(order: 2, weekday: .wednesday, subject: english, subjectName: english.name, subjectColorHex: english.colorHex, teacher: englishTeacher),
            ScheduleLesson(order: 1, weekday: .thursday, subject: ukrainian, subjectName: ukrainian.name, subjectColorHex: ukrainian.colorHex, teacher: ukrainianTeacher),
            ScheduleLesson(order: 2, weekday: .friday, subject: history, subjectName: history.name, subjectColorHex: history.colorHex, teacher: historyTeacher)
        ]

        lessons.forEach { context.insert($0) }

        let homeworks = [
            Homework(
                subject: math,
                subjectName: math.name,
                subjectColorHex: math.colorHex,
                taskDescription: "Розвʼязати задачі 145-152 і повторити дроби.",
                dueDate: dateByAdding(days: 1),
                status: .active
            ),
            Homework(
                subject: ukrainian,
                subjectName: ukrainian.name,
                subjectColorHex: ukrainian.colorHex,
                taskDescription: "Підготувати короткий переказ оповідання.",
                dueDate: dateByAdding(days: -2),
                status: .active
            ),
            Homework(
                subject: history,
                subjectName: history.name,
                subjectColorHex: history.colorHex,
                taskDescription: "Виписати ключові дати до теми Київської Русі.",
                dueDate: nil,
                status: .active
            ),
            Homework(
                subject: english,
                subjectName: english.name,
                subjectColorHex: english.colorHex,
                taskDescription: "Вивчити слова з Unit 4 та виконати вправу 6.",
                dueDate: dateByAdding(days: -1),
                status: .completed
            )
        ]

        homeworks.forEach { context.insert($0) }
        try? context.save()
    }

}
