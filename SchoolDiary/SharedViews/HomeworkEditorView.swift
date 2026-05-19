//
//  HomeworkEditorView.swift
//  SchoolDiary
//
//  Created by Olena Pavlyshyna on 18.05.2026.
//

import SwiftUI
import SwiftData

struct HomeworkEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Subject.name)]) private var subjects: [Subject]
    @Query(sort: [SortDescriptor(\ScheduleLesson.weekdayRawValue), SortDescriptor(\ScheduleLesson.order)]) private var lessons: [ScheduleLesson]

    let homework: Homework?
    let lesson: ScheduleLesson?

    @State private var subjectMode: HomeworkSubjectMode
    @State private var selectedSubjectID: PersistentIdentifier?
    @State private var newSubjectName: String
    @State private var selectedColorHex: String
    @State private var taskDescription: String
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var status: HomeworkStatus
    @State private var isDueDateCalendarExpanded: Bool

    private var trimmedSubjectName: String {
        newSubjectName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedTaskDescription: String {
        taskDescription.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        let hasSubject: Bool

        switch subjectMode {
        case .existing:
            hasSubject = selectedSubjectID != nil
        case .new:
            hasSubject = !trimmedSubjectName.isEmpty
        }

        return hasSubject && !trimmedTaskDescription.isEmpty
    }

    private var selectedSubject: Subject? {
        switch subjectMode {
        case .existing:
            guard let selectedSubjectID else {
                return nil
            }

            if let subject = subjects.first(where: { $0.persistentModelID == selectedSubjectID }) {
                return subject
            }

            if let lessonSubject = lesson?.subject, lessonSubject.persistentModelID == selectedSubjectID {
                return lessonSubject
            }

            return nil
        case .new:
            guard !trimmedSubjectName.isEmpty else {
                return nil
            }

            return subjects.first { $0.name.localizedCaseInsensitiveCompare(trimmedSubjectName) == .orderedSame }
        }
    }

    private var scheduleLookupName: String? {
        switch subjectMode {
        case .existing:
            return selectedSubject?.name
        case .new:
            return trimmedSubjectName.isEmpty ? nil : trimmedSubjectName
        }
    }

    private var scheduledWeekdaysForSelectedSubject: Set<Weekday> {
        let selectedSubjectID = selectedSubject?.persistentModelID
        let selectedSubjectName = scheduleLookupName

        return Set(lessons.compactMap { lesson in
            if let selectedSubjectID, lesson.subject?.persistentModelID == selectedSubjectID {
                return lesson.weekday
            }

            guard let selectedSubjectName else {
                return nil
            }

            return lesson.displaySubjectName.localizedCaseInsensitiveCompare(selectedSubjectName) == .orderedSame ? lesson.weekday : nil
        })
    }

    private var dueDateAccentColorHex: String {
        selectedSubject?.colorHex ?? selectedColorHex
    }

    init(homework: Homework? = nil, lesson: ScheduleLesson? = nil) {
        self.homework = homework
        self.lesson = lesson

        let presetSubject = homework?.subject ?? lesson?.subject
        let presetSubjectName = homework?.subject == nil ? homework?.subjectName ?? lesson?.displaySubjectName ?? "" : ""
        let startsWithExistingSubject = presetSubject != nil || (homework == nil && lesson == nil)
        _subjectMode = State(initialValue: startsWithExistingSubject ? .existing : .new)
        _selectedSubjectID = State(initialValue: presetSubject?.persistentModelID)
        _newSubjectName = State(initialValue: presetSubjectName)
        _selectedColorHex = State(initialValue: homework?.displayColorHex ?? lesson?.displayColorHex ?? SubjectPalette.fallbackHex)
        _taskDescription = State(initialValue: homework?.taskDescription ?? "")
        _hasDueDate = State(initialValue: homework?.dueDate != nil)
        let startsWithDueDate = homework?.dueDate != nil
        _dueDate = State(initialValue: homework?.dueDate ?? Date())
        _status = State(initialValue: homework?.status ?? .active)
        _isDueDateCalendarExpanded = State(initialValue: startsWithDueDate)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Предмет") {
                    Picker("Тип", selection: $subjectMode) {
                        ForEach(HomeworkSubjectMode.allCases) { mode in
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

                Section("Завдання") {
                    Toggle("Є термін виконання", isOn: $hasDueDate)

                    if hasDueDate {
                        DisclosureGroup(isExpanded: $isDueDateCalendarExpanded) {
                            SubjectDueDateCalendarView(
                                selection: $dueDate,
                                highlightedWeekdays: scheduledWeekdaysForSelectedSubject,
                                accentColorHex: dueDateAccentColorHex,
                                highlightedSubjectName: scheduleLookupName
                            ) {
                                withAnimation {
                                    isDueDateCalendarExpanded = false
                                }
                            }
                        } label: {
                            LabeledContent("Дата", value: dueDate.schoolDiaryShortDate)
                        }
                    }

                    TextEditor(text: $taskDescription)
                        .frame(minHeight: 110)

                    Picker("Статус", selection: $status) {
                        ForEach(HomeworkStatus.allCases) { status in
                            Label(status.title, systemImage: status.systemImage).tag(status)
                        }
                    }
                }
            }
            .navigationTitle(homework == nil ? "Нове завдання" : "Редагувати завдання")
            .onChange(of: hasDueDate) { _, enabled in
                isDueDateCalendarExpanded = enabled
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Зберегти") {
                        saveHomework()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear(perform: prepareDefaults)
        }
    }

    private func prepareDefaults() {
        if subjects.isEmpty, selectedSubjectID == nil {
            subjectMode = .new
        }
    }

    private func saveHomework() {
        guard let subject = selectedOrCreatedSubject() else {
            return
        }

        let selectedDueDate = hasDueDate ? dueDate : nil

        if let homework {
            homework.subject = subject
            homework.subjectName = subject.name
            homework.subjectColorHex = subject.colorHex
            homework.taskDescription = trimmedTaskDescription
            homework.dueDate = selectedDueDate
            homework.status = status
        } else {
            let homework = Homework(
                subject: subject,
                subjectName: subject.name,
                subjectColorHex: subject.colorHex,
                taskDescription: trimmedTaskDescription,
                dueDate: selectedDueDate,
                status: status
            )
            modelContext.insert(homework)
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

            if let selectedSubject = subjects.first(where: { $0.persistentModelID == selectedSubjectID }) {
                return selectedSubject
            }

            if let lessonSubject = lesson?.subject, lessonSubject.persistentModelID == selectedSubjectID {
                return lessonSubject
            }

            return nil
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
}
