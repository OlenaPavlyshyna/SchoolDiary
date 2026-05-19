//
//  TeacherEditorSheet.swift
//  SchoolDiary
//
//  Created by Olena Pavlyshyna on 18.05.2026.
//

import SwiftUI
import SwiftData

struct TeacherEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Teacher.name)]) private var teachers: [Teacher]

    let teacher: Teacher?
    @State private var name: String

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedName.isEmpty
    }

    init(teacher: Teacher?) {
        self.teacher = teacher
        _name = State(initialValue: teacher?.name ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Вчитель") {
                    TextField("Імʼя", text: $name)
                        .textContentType(.name)
                }
            }
            .navigationTitle(teacher == nil ? "Новий вчитель" : "Редагувати вчителя")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Зберегти") {
                        saveTeacher()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private func saveTeacher() {
        if let duplicate = teachers.first(where: { $0 !== teacher && $0.name.localizedCaseInsensitiveCompare(trimmedName) == .orderedSame }) {
            if teacher == nil {
                duplicate.name = trimmedName
            }
            dismiss()
            return
        }

        if let teacher {
            teacher.name = trimmedName
        } else {
            modelContext.insert(Teacher(name: trimmedName))
        }

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    TeacherEditorSheet(teacher: nil)
}
