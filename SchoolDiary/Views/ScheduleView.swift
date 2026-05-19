import SwiftUI
import SwiftData

struct ScheduleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.editMode) private var editMode
    @Query(sort: [SortDescriptor(\ScheduleLesson.weekdayRawValue), SortDescriptor(\ScheduleLesson.order)]) private var lessons: [ScheduleLesson]
    @State private var selectedWeekday = Weekday.currentSchoolDay
    @State private var hasAppliedCurrentWeekday = false
    @State private var isAddingLesson = false
    @State private var editingLesson: ScheduleLesson?

    private var dayLessons: [ScheduleLesson] {
        lessons
            .filter { $0.weekday == selectedWeekday }
            .sorted { first, second in
                if first.order == second.order {
                    return first.displaySubjectName < second.displaySubjectName
                }
                return first.order < second.order
            }
    }

    private var nextOrder: Int {
        (dayLessons.map(\.order).max() ?? 0) + 1
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("День", selection: $selectedWeekday) {
                    ForEach(Weekday.allCases) { weekday in
                        Text(weekday.shortTitle).tag(weekday)
                    }
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top, .bottom])

                List {
                    if dayLessons.isEmpty {
                        ContentUnavailableView {
                            Label("Немає уроків", systemImage: "calendar.badge.plus")
                        } description: {
                            Text("Додайте уроки для цього дня")
                        } actions: {
                            Button {
                                isAddingLesson = true
                            } label: {
                                HStack
                                {
                                    Image(systemName: "plus")
                                    Text("Додати урок")
                                }
                                .padding(8)
                            }
                            .foregroundStyle(.primary)
                            .fontWeight(.bold)
                            .buttonStyle(.bordered)
                            
                        }
                    } else {
                        ForEach(dayLessons) { lesson in
                            NavigationLink {
                                LessonDetailView(lesson: lesson)
                            } label: {
                                ScheduleLessonRow(lesson: lesson)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteLesson(lesson)
                                } label: {
                                    Label("Видалити", systemImage: "trash")
                                }

                                Button {
                                    editingLesson = lesson
                                } label: {
                                    Label("Редагувати", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                        .onDelete(perform: deleteLessons)
                        .onMove(perform: moveLessons)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle(selectedWeekday.title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                        .disabled(dayLessons.isEmpty)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingLesson = true
                    } label: {
                        Label("Додати урок", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingLesson) {
                LessonEditorView(weekday: selectedWeekday, nextOrder: nextOrder)
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $editingLesson) { lesson in
                LessonEditorView(weekday: lesson.weekday, lesson: lesson, nextOrder: lesson.order)
                    .presentationDragIndicator(.visible)
            }
            .onChange(of: dayLessons.isEmpty, initial: true) { _, isEmpty in
                if isEmpty {
                    editMode?.wrappedValue = .inactive
                }
            }
            .onAppear(perform: applyCurrentWeekday)
        }
    }

    private func applyCurrentWeekday() {
        guard !hasAppliedCurrentWeekday else {
            return
        }

        selectedWeekday = .currentSchoolDay
        hasAppliedCurrentWeekday = true
    }

    private func moveLessons(from source: IndexSet, to destination: Int) {
        var reorderedLessons = dayLessons
        reorderedLessons.move(fromOffsets: source, toOffset: destination)
        updateOrder(for: reorderedLessons)
    }

    private func deleteLessons(offsets: IndexSet) {
        var remainingLessons = dayLessons
        let lessonsToDelete = offsets.map { dayLessons[$0] }
        remainingLessons.remove(atOffsets: offsets)

        for lesson in lessonsToDelete {
            modelContext.delete(lesson)
        }

        updateOrder(for: remainingLessons)
    }

    private func deleteLesson(_ lesson: ScheduleLesson) {
        let remainingLessons = dayLessons.filter { $0 !== lesson }
        modelContext.delete(lesson)
        updateOrder(for: remainingLessons)
    }

    private func updateOrder(for orderedLessons: [ScheduleLesson]) {
        for (index, lesson) in orderedLessons.enumerated() {
            lesson.order = index + 1
        }

        try? modelContext.save()
    }
}

#Preview {
    ScheduleView()
        .modelContainer(SampleData.preview)
}
