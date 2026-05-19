import SwiftUI

struct SubjectDueDateCalendarView: View {
    @Binding var selection: Date

    let highlightedWeekdays: Set<Weekday>
    let accentColorHex: String
    let highlightedSubjectName: String?
    let onDateSelected: () -> Void

    @State private var displayedMonth: Date

    private let columns = Array(repeating: GridItem(.flexible(minimum: 32), spacing: 6), count: 7)
    private let weekdayTitles = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Нд"]

    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar
    }

    private var accentColor: Color {
        Color(hex: accentColorHex)
    }

    private var monthTitle: String {
        displayedMonth.formatted(.dateTime.month(.wide).year())
    }

    private var calendarDays: [CalendarDay] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let dayRange = calendar.range(of: .day, in: .month, for: displayedMonth) else {
            return []
        }

        let firstWeekdayOffset = weekdayOffset(for: monthInterval.start)
        var days: [CalendarDay] = (0..<firstWeekdayOffset).map { index in
            CalendarDay(id: "leading-\(index)", date: nil)
        }

        for dayOffset in 0..<dayRange.count {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: monthInterval.start) {
                days.append(CalendarDay(id: "day-\(date.timeIntervalSinceReferenceDate)", date: date))
            }
        }

        while !days.isEmpty, days.count % 7 != 0 {
            days.append(CalendarDay(id: "trailing-\(days.count)", date: nil))
        }

        return days
    }

    init(
        selection: Binding<Date>,
        highlightedWeekdays: Set<Weekday>,
        accentColorHex: String,
        highlightedSubjectName: String?,
        onDateSelected: @escaping () -> Void = {}
    ) {
        _selection = selection
        self.highlightedWeekdays = highlightedWeekdays
        self.accentColorHex = accentColorHex
        self.highlightedSubjectName = highlightedSubjectName
        self.onDateSelected = onDateSelected
        _displayedMonth = State(initialValue: Self.monthAnchor(for: selection.wrappedValue))
    }

    var body: some View {
        VStack(spacing: 12) {
            monthControls
            weekdayHeader
            daysGrid
        }
        .padding(.vertical, 8)
        .onChange(of: selection) { _, newValue in
            displayedMonth = Self.monthAnchor(for: newValue)
        }
    }

    private var monthControls: some View {
        HStack {
            Button {
                moveDisplayedMonth(by: -1)
            } label: {
                Label("Попередній місяць", systemImage: "chevron.left")
            }
            .labelStyle(.iconOnly)

            Spacer()

            Text(monthTitle)
                .font(.headline)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                moveDisplayedMonth(by: 1)
            } label: {
                Label("Наступний місяць", systemImage: "chevron.right")
            }
            .labelStyle(.iconOnly)
        }
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(weekdayTitles, id: \.self) { title in
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .accessibilityHidden(true)
    }

    private var daysGrid: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(calendarDays) { day in
                if let date = day.date {
                    CalendarDateButton(
                        date: date,
                        selection: $selection,
                        isSelected: calendar.isDate(date, inSameDayAs: selection),
                        isToday: calendar.isDateInToday(date),
                        isHighlighted: isHighlighted(date),
                        accentColor: accentColor,
                        highlightedSubjectName: highlightedSubjectName,
                        onDateSelected: onDateSelected
                    )
                } else {
                    Color.clear
                        .frame(height: 36)
                        .accessibilityHidden(true)
                }
            }
        }
    }

    private func moveDisplayedMonth(by months: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: months, to: displayedMonth) else {
            return
        }

        displayedMonth = Self.monthAnchor(for: newMonth)
    }

    private func isHighlighted(_ date: Date) -> Bool {
        guard let weekday = schoolWeekday(for: date) else {
            return false
        }

        return highlightedWeekdays.contains(weekday)
    }

    private func schoolWeekday(for date: Date) -> Weekday? {
        switch calendar.component(.weekday, from: date) {
        case 2:
            return .monday
        case 3:
            return .tuesday
        case 4:
            return .wednesday
        case 5:
            return .thursday
        case 6:
            return .friday
        default:
            return nil
        }
    }

    private func weekdayOffset(for date: Date) -> Int {
        (calendar.component(.weekday, from: date) + 5) % 7
    }

    private static func monthAnchor(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }
}

private struct CalendarDateButton: View {
    let date: Date
    @Binding var selection: Date
    let isSelected: Bool
    let isToday: Bool
    let isHighlighted: Bool
    let accentColor: Color
    let highlightedSubjectName: String?
    let onDateSelected: () -> Void

    private var calendar: Calendar {
        Calendar.current
    }

    private var dayNumber: String {
        date.formatted(.dateTime.day())
    }

    private var foregroundStyle: Color {
        if isSelected && isHighlighted {
            return .white
        }

        if isHighlighted {
            return accentColor
        }

        return .primary
    }

    var body: some View {
        Button {
            selection = calendar.startOfDay(for: date)
            onDateSelected()
        } label: {
            Text(dayNumber)
                .font(.callout.weight(isSelected || isHighlighted ? .semibold : .regular))
                .foregroundStyle(foregroundStyle)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background {
                    Circle()
                        .fill(backgroundColor)
                }
                .overlay {
                    Circle()
                        .strokeBorder(borderColor, lineWidth: borderWidth)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(isSelected ? "Вибрано" : "")
        .accessibilityHint(accessibilityHint)
    }

    private var backgroundColor: Color {
        if isSelected && isHighlighted {
            return accentColor
        }

        if isHighlighted {
            return accentColor.opacity(0.18)
        }

        return .clear
    }

    private var borderColor: Color {
        if isSelected {
            return accentColor
        }

        if isToday {
            return Color.secondary.opacity(0.45)
        }

        return .clear
    }

    private var borderWidth: CGFloat {
        isSelected ? 2 : 1
    }

    private var accessibilityLabel: String {
        date.formatted(.dateTime.weekday(.wide).day().month(.wide).year())
    }

    private var accessibilityHint: String {
        guard isHighlighted else {
            return ""
        }

        if let highlightedSubjectName, !highlightedSubjectName.isEmpty {
            return "У цей день є \(highlightedSubjectName)"
        }

        return "У цей день є вибраний предмет"
    }
}

private struct CalendarDay: Identifiable {
    let id: String
    let date: Date?
}
