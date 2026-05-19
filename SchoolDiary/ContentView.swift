//
//  ContentView.swift
//  SchoolDiary
//
//  Created by Olena Pavlyshyna on 17.05.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            ScheduleView()
                .tabItem {
                    Label("Розклад", systemImage: "calendar")
                }

            HomeworkView()
                .tabItem {
                    Label("Домашні", systemImage: "checklist")
                }

            SettingsView()
                .tabItem {
                    Label("Налаштування", systemImage: "gearshape")
                }
        }

    }
}

#Preview {
    ContentView()
        .modelContainer(SampleData.preview)
}
