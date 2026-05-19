import SwiftUI
import SwiftData

private enum LessonSubjectMode: String, CaseIterable, Identifiable {
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

struct LessonEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Subject.name)]) private var subjects: [Subject]
    @Query(sort: [SortDescriptor(\Teacher.name)]) private var teachers: [Teacher]

    let weekday: Weekday
    let lesson: ScheduleLesson?
    let nextOrder: Int

    @State private var subjectMode: LessonSubjectMode
    @State private var selectedSubjectID: PersistentIdentifier?
    @State private var newSubjectName: String
    @State private var selectedColorHex: String
    @State private var teacherMode: LessonTeacherMode
    @State private var selectedTeacherID: PersistentIdentifier?
    @State private var newTeacherName: String

    private var trimmedSubjectName: String {
        newSubjectName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedTeacherName: String {
        newTeacherName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        switch subjectMode {
        case .existing:
            return selectedSubjectID != nil
        case .new:
            return !trimmedSubjectName.isEmpty
        }
    }

    init(weekday: Weekday, lesson: ScheduleLesson? = nil, nextOrder: Int) {
        self.weekday = weekday
        self.lesson = lesson
        self.nextOrder = nextOrder

        let startsWithExistingSubject = lesson?.subject != nil || lesson == nil
        _subjectMode = State(initialValue: startsWithExistingSubject ? .existing : .new)
        _selectedSubjectID = State(initialValue: lesson?.subject?.persistentModelID)
        _newSubjectName = State(initialValue: lesson?.subject == nil ? lesson?.subjectName ?? "" : "")
        _selectedColorHex = State(initialValue: lesson?.displayColorHex ?? SubjectPalette.fallbackHex)
        _teacherMode = State(initialValue: lesson?.teacher == nil ? .none : .existing)
        _selectedTeacherID = State(initialValue: lesson?.teacher?.persistentModelID)
        _newTeacherName = State(initialValue: "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("День") {
                    LabeledContent("День тижня", value: weekday.title)
                    LabeledContent("Номер уроку", value: "\(lesson?.order ?? nextOrder)")
                }

                Section("Предмет") {
                    Picker("Тип", selection: $subjectMode) {
                        ForEach(LessonSubjectMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    if subjectMode == .existing {
                        Picker("Предмет", selection: $selectedSubjectID) {
                            Text("Вибрати").tag(nil as PersistentIdentifier?)

                            ForEach(subjects) { subject in
                                Text(subject.name).tag(Optional(subject.persistentModelID))
                            }
                        }
                    } else {
                        TextField("Назва предмета", text: $newSubjectName)
                        ColorSwatchPicker(selection: $selectedColorHex)
                    }
                }

                Section("Вчитель") {
                    teacherSection
                }
            }
            .navigationTitle(lesson == nil ? "Новий урок" : "Редагувати урок")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Зберегти") {
                        saveLesson()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear(perform: prepareDefaults)
        }
    }

    @ViewBuilder
    private var teacherSection: some View {
        Picker("Вчитель", selection: $teacherMode) {
            ForEach(LessonTeacherMode.allCases) { mode in
                Text(mode.title).tag(mode)
            }
        }
        .pickerStyle(.segmented)

        if teacherMode == .existing {
            Picker("Вчитель", selection: $selectedTeacherID) {
                Text("Вибрати").tag(nil as PersistentIdentifier?)

                ForEach(teachers) { teacher in
                    Text(teacher.name).tag(Optional(teacher.persistentModelID))
                }
            }
        } else if teacherMode == .new {
            TextField("Імʼя вчителя", text: $newTeacherName)
        }
    }

    private func prepareDefaults() {
        if subjects.isEmpty {
            subjectMode = .new
        }

        if lesson == nil, teacherMode == .none, !teachers.isEmpty {
            teacherMode = .existing
        } else if teacherMode == .existing, teachers.isEmpty {
            teacherMode = .new
        }
    }

    private func saveLesson() {
        guard let subject = selectedOrCreatedSubject() else {
            return
        }

        let teacher = selectedOrCreatedTeacher()

        if let lesson {
            lesson.subject = subject
            lesson.subjectName = subject.name
            lesson.subjectColorHex = subject.colorHex
            lesson.teacher = teacher
        } else {
            let newLesson = ScheduleLesson(
                order: nextOrder,
                weekday: weekday,
                subject: subject,
                subjectName: subject.name,
                subjectColorHex: subject.colorHex,
                teacher: teacher
            )
            modelContext.insert(newLesson)
        }

        try? modelContext.save()
        dismiss()
    }

    private func selectedOrCreatedSubject() -> Subject? {
        switch subjectMode {
        case .existing:
            guard let selectedSubjectID else {
                return nil
            }
            return subjects.first { $0.persistentModelID == selectedSubjectID }
        case .new:
            guard !trimmedSubjectName.isEmpty else {
                return nil
            }

            if let existingSubject = subjects.first(where: { $0.name.localizedCaseInsensitiveCompare(trimmedSubjectName) == .orderedSame }) {
                return existingSubject
            }

            let subject = Subject(name: trimmedSubjectName, colorHex: selectedColorHex)
            modelContext.insert(subject)
            return subject
        }
    }

    private func selectedOrCreatedTeacher() -> Teacher? {
        switch teacherMode {
        case .none:
            return nil
        case .existing:
            guard let selectedTeacherID else {
                return nil
            }
            return teachers.first { $0.persistentModelID == selectedTeacherID }
        case .new:
            guard !trimmedTeacherName.isEmpty else {
                return nil
            }

            if let existingTeacher = teachers.first(where: { $0.name.localizedCaseInsensitiveCompare(trimmedTeacherName) == .orderedSame }) {
                return existingTeacher
            }

            let teacher = Teacher(name: trimmedTeacherName)
            modelContext.insert(teacher)
            return teacher
        }
    }
}

#Preview {
    LessonEditorView(weekday: .monday, nextOrder: 4)
        .modelContainer(SampleData.preview)
}
