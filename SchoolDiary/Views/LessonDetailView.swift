import SwiftUI
import SwiftData

struct LessonDetailView: View {
    @Environment(\.modelContext) private var modelContext

    let lesson: ScheduleLesson
    @Query(sort: [SortDescriptor(\Homework.createdAt, order: .reverse)]) private var homeworks: [Homework]
    @State private var isAddingHomework = false
    @State private var editingHomework: Homework?

    private var recentHomeworks: [Homework] {
        homeworks
            .filter { homework in
                homework.isRecent && homework.matches(lesson: lesson)
            }
            .sortedByHomeworkPriority()
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 12) {
                    SubjectColorDot(hex: lesson.displayColorHex, size: 18)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lesson.displaySubjectName)
                            .font(.title3.weight(.semibold))

                        if let teacherName = lesson.teacher?.name, !teacherName.isEmpty {
                            Text(teacherName)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            ForEach(HomeworkSectionKind.allCases) { section in
                let items = recentHomeworks.filter { $0.sectionKind == section }
                if !items.isEmpty {
                    Section {
                        ForEach(items) { homework in
                            Button {
                                editingHomework = homework
                            } label: {
                                HomeworkCompactRow(homework: homework)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .leading) {
                                Button {
                                    toggleStatus(for: homework)
                                } label: {
                                    Label(
                                        homework.status == .completed ? "Активне" : "Виконане",
                                        systemImage: homework.status == .completed ? "circle" : "checkmark.circle"
                                    )
                                }
                                .tint(homework.status == .completed ? .orange : .green)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteHomework(homework)
                                } label: {
                                    Label("Видалити", systemImage: "trash")
                                }

                                Button {
                                    editingHomework = homework
                                } label: {
                                    Label("Редагувати", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                        .onDelete { offsets in
                            deleteHomeworks(items: items, offsets: offsets)
                        }
                    } header: {
                        Label(section.title, systemImage: section.systemImage)
                    }
                }
            }

            if recentHomeworks.isEmpty {
                ContentUnavailableView {
                    Label("Актуальних завдань немає", systemImage: "checklist")
                } description: {
                    Text("Додайте нове завдання для цього уроку")
                } actions: {
                    Button {
                        isAddingHomework = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Додати завдання")
                        }
                        .padding(8)
                    }
                    .foregroundStyle(.primary)
                    .fontWeight(.bold)
                    .buttonStyle(.bordered)
                }
            }
        }
        .navigationTitle("Деталі уроку")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isAddingHomework = true
                } label: {
                    Label("Додати завдання", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddingHomework) {
            HomeworkEditorView(lesson: lesson)
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $editingHomework) { homework in
            HomeworkEditorView(homework: homework, lesson: lesson)
                .presentationDragIndicator(.visible)
        }
    }

    private func toggleStatus(for homework: Homework) {
        homework.status = homework.status == .completed ? .active : .completed
        try? modelContext.save()
    }

    private func deleteHomework(_ homework: Homework) {
        modelContext.delete(homework)
        try? modelContext.save()
    }

    private func deleteHomeworks(items: [Homework], offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(items[offset])
        }
        try? modelContext.save()
    }
}

private struct HomeworkCompactRow: View {
    let homework: Homework

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(homework.taskDescription)
                .font(.body)

            HStack(spacing: 10) {
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
        .padding(.vertical, 4)
    }
}

private extension Homework {
    func matches(lesson: ScheduleLesson) -> Bool {
        if let homeworkSubject = subject, let lessonSubject = lesson.subject {
            return homeworkSubject.persistentModelID == lessonSubject.persistentModelID
        }

        return displaySubjectName.localizedCaseInsensitiveCompare(lesson.displaySubjectName) == .orderedSame
    }
}

#Preview {
    NavigationStack {
        LessonDetailView(
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
    .modelContainer(SampleData.preview)
}
