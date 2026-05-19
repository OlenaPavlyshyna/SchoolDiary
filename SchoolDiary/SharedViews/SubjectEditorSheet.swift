//
//  SubjectEditorSheet.swift
//  SchoolDiary
//
//  Created by Olena Pavlyshyna on 18.05.2026.
//

import SwiftUI
import SwiftData

struct SubjectEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Subject.name)]) private var subjects: [Subject]

    let subject: Subject?
    @State private var name: String
    @State private var colorHex: String

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedName.isEmpty
    }

    init(subject: Subject?) {
        self.subject = subject
        _name = State(initialValue: subject?.name ?? "")
        _colorHex = State(initialValue: subject?.colorHex ?? SubjectPalette.fallbackHex)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Предмет") {
                    TextField("Назва", text: $name)
                    ColorSwatchPicker(selection: $colorHex)
                }
            }
            .navigationTitle(subject == nil ? "Новий предмет" : "Редагувати предмет")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Зберегти") {
                        saveSubject()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private func saveSubject() {
        if let duplicate = subjects.first(where: { $0 !== subject && $0.name.localizedCaseInsensitiveCompare(trimmedName) == .orderedSame }) {
            if subject == nil {
                duplicate.colorHex = colorHex
            }
            dismiss()
            return
        }

        if let subject {
            subject.name = trimmedName
            subject.colorHex = colorHex
        } else {
            modelContext.insert(Subject(name: trimmedName, colorHex: colorHex))
        }

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    SubjectEditorSheet(subject: nil)
}
