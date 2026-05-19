import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [DiaryProfile]
    @Query(sort: [SortDescriptor(\Subject.name)]) private var subjects: [Subject]
    @Query(sort: [SortDescriptor(\Teacher.name)]) private var teachers: [Teacher]
    @State private var teacherEditor: TeacherEditorState?
    @State private var subjectEditor: SubjectEditorState?
    @State private var selectedSettingsSection: SettingsSection = .profile

    private var profile: DiaryProfile? {
        profiles.first
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Розділ налаштувань", selection: $selectedSettingsSection) {
                        ForEach(SettingsSection.allCases) { section in
                            Text(section.title).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                switch selectedSettingsSection {
                case .profile:
                    profileSection
                case .subjects:
                    Section("Предмети") {
                        subjectsSection
                    }
                case .teachers:
                    Section("Вчителі") {
                        teachersSection
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Налаштування")
            .toolbar {
                if selectedSettingsSection.supportsEditing {
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                }
            }
            .sheet(item: $teacherEditor) { state in
                TeacherEditorSheet(teacher: state.teacher)
                    .presentationDetents([.height(250)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $subjectEditor) { state in
                SubjectEditorSheet(subject: state.subject)
                    .presentationDetents([.height(400)])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    @ViewBuilder
    var profileSection: some View {
        if let profile {
            ProfileFields(profile: profile)
        } else {
            Section("Власник щоденника") {
                Button {
                    modelContext.insert(DiaryProfile())
                    try? modelContext.save()
                } label: {
                    Label("Створити профіль", systemImage: "person.badge.plus")
                }
            }
        }
    }
    
    @ViewBuilder
    var subjectsSection: some View {
        if subjects.isEmpty {
            Text("Список предметів порожній")
                .foregroundStyle(.secondary)
        }

        ForEach(subjects) { subject in
            HStack(spacing: 12) {
                SubjectColorDot(hex: subject.colorHex)
                Text(subject.name)
                Spacer()
                Button {
                    subjectEditor = SubjectEditorState(subject: subject)
                } label: {
                    Image(systemName: "pencil")
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Редагувати предмет")
            }
        }
        .onDelete(perform: deleteSubjects)

        Button {
            subjectEditor = SubjectEditorState(subject: nil)
        } label: {
            Label("Додати предмет", systemImage: "plus")
        }
    }

    private func deleteSubjects(offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(subjects[offset])
        }
        try? modelContext.save()
    }
    
    @ViewBuilder
    var teachersSection: some View {
        if teachers.isEmpty {
            Text("Список вчителів порожній")
                .foregroundStyle(.secondary)
        }

        ForEach(teachers) { teacher in
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle")
                    .foregroundStyle(.secondary)
                Text(teacher.name)
                Spacer()
                Button {
                    teacherEditor = TeacherEditorState(teacher: teacher)
                } label: {
                    Image(systemName: "pencil")
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Редагувати вчителя")
            }
        }
        .onDelete(perform: deleteTeachers)

        Button {
            teacherEditor = TeacherEditorState(teacher: nil)
        } label: {
            Label("Додати вчителя", systemImage: "plus")
        }
    }

    private func deleteTeachers(offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(teachers[offset])
        }
        try? modelContext.save()
    }
}


private struct TeacherEditorState: Identifiable {
    let id = UUID()
    let teacher: Teacher?
}

private struct SubjectEditorState: Identifiable {
    let id = UUID()
    let subject: Subject?
}

private enum SettingsSection: String, CaseIterable, Identifiable {
    case profile
    case subjects
    case teachers

    var id: Self { self }

    var title: String {
        switch self {
        case .profile:
            return "Профіль"
        case .subjects:
            return "Предмети"
        case .teachers:
            return "Вчителі"
        }
    }

    var supportsEditing: Bool {
        switch self {
        case .profile:
            return false
        case .subjects, .teachers:
            return true
        }
    }
}


#Preview {
    SettingsView()
        .modelContainer(SampleData.preview)
}

