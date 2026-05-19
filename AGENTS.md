# SchoolDiary Project Notes

## Overview

SchoolDiary is a SwiftUI school diary app backed by SwiftData. It stores a weekday schedule, subjects, teachers, homework, and the diary owner's profile.

## Architecture

- SwiftUI is the UI layer, with `ContentView` as the tab root.
- SwiftData model classes live in `SchoolDiary/DataModel`: `DiaryProfile`, `Teacher`, `Subject`, `ScheduleLesson`, and `Homework`.
- Supporting data-model types are grouped under `SchoolDiary/DataModel/Enums` and `SchoolDiary/DataModel/SupportingTypes`.
- Feature views are split by workflow:
  - `ScheduleView.swift` for weekday schedule and lesson editing.
  - `HomeworkView.swift` for homework lists, sorting, and editing.
  - `SettingsView.swift` for profile, subjects, and teachers.
  - `DiaryComponents.swift` for reusable visual elements.
  - `SampleData.swift` for first-run and preview data.
- Relationships use optional references plus fallback display names/colors so schedule and homework rows can still render if a related subject is removed.

## Conventions

- Prefer SwiftUI-native views and SwiftData `@Query`/`ModelContext`.
- Keep persisted model data simple: store raw enum values and color hex strings rather than SwiftUI-only types.
- Use async/await when asynchronous work is needed; avoid Combine.
- Use form-based editing for CRUD flows.

## Build and Run

Open `SchoolDiary.xcodeproj` in Xcode and build the active `SchoolDiary` scheme. The app seeds sample data on first launch when the subject list is empty.

## Gotchas

- The original template used the misspelled `SchookDiary`; visible project groups, target, product, and app entry file were renamed to `SchoolDiary` through Xcode tooling.
- Do not hand-edit `SchoolDiary.xcodeproj/project.pbxproj` while Xcode is open. Change build settings such as bundle identifier through Xcode.
- SwiftData previews use an in-memory `ModelContainer` from `SampleData.previewContainer`.
- The old catch-all `Items.swift` file was split into focused files; add new helper types to the matching `DataModel` subfolder instead of recreating a grab-bag file.
