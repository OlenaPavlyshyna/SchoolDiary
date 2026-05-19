import SwiftUI
import SwiftData

struct HomeworkView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Homework.createdAt, order: .reverse)]) private var homeworks: [Homework]
    @State private var isAddingHomework = false
    @State private var editingHomework: Homework?
    
    private var sortedHomeworks: [Homework] {
        homeworks.sortedByHomeworkPriority()
    }
    
    var body: some View {
        NavigationStack {
            List {
                if homeworks.isEmpty {
                    ContentUnavailableView(
                        "Домашніх завдань немає",
                        systemImage: "checklist",
                        description: Text("Додайте перше завдання")
                    )
                } else {
                    homeworksList
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Домашні завдання")
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
                HomeworkEditorView()
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $editingHomework) { homework in
                HomeworkEditorView(homework: homework)
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    private var homeworksList: some View {
        ForEach(HomeworkSectionKind.allCases) { section in
            let items = sortedHomeworks.filter { $0.sectionKind == section }
            if !items.isEmpty {
                Section {
                    ForEach(items) { homework in
                        Button {
                            editingHomework = homework
                        } label: {
                            HomeworkRow(homework: homework)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .leading) {
                            changeStatus(homework)
                        }
                        .swipeActions(edge: .trailing) {
                            deleteHomework(homework)
                            
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
    }
    
    private func changeStatus(_ homework: Homework) -> some View {
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
    
    func deleteHomework(_ homework: Homework) -> some View {
        Button(role: .destructive) {
            modelContext.delete(homework)
            try? modelContext.save()
        } label: {
            Label("Видалити", systemImage: "trash")
        }
    }
    
    private func toggleStatus(for homework: Homework) {
        homework.status = homework.status == .completed ? .active : .completed
        try? modelContext.save()
    }
    
    private func deleteHomeworks(items: [Homework], offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(items[offset])
        }
        try? modelContext.save()
    }
}

#Preview {
    HomeworkView()
}
