import SwiftUI

struct SubjectColorDot: View {
    let hex: String
    var size: CGFloat = 14

    var body: some View {
        Circle()
            .fill(Color(hex: hex))
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

struct SubjectBadge: View {
    let title: String
    let colorHex: String

    var body: some View {
        HStack(spacing: 8) {
            SubjectColorDot(hex: colorHex)
            Text(title)
                .font(.headline)
        }
    }
}

struct ColorSwatchPicker: View {
    @Binding var selection: String

    private let columns = [
        GridItem(.adaptive(minimum: 44), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(SubjectPalette.options) { option in
                Button {
                    selection = option.hex
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(hex: option.hex))
                            .frame(width: 32, height: 32)

                        if selection == option.hex {
                            Image(systemName: "checkmark")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(option.name)
            }
        }
    }
}

struct HomeworkStatusLabel: View {
    let homework: Homework

    var body: some View {
        Label(homework.status.title, systemImage: homework.status.systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(homework.status == .completed ? .green : .secondary)
    }
}

extension Date {
    var schoolDiaryShortDate: String {
        formatted(.dateTime.day().month(.abbreviated))
    }
}
