# SchoolDiary Journal

## The Big Picture

SchoolDiary is a digital school diary: the thing that remembers Monday's math class, Friday's history lesson, and the homework that quietly becomes urgent if nobody looks at it. Think of it as a tidy backpack pocket where schedule, teachers, subjects, and assignments each get their own labeled folder.

## Architecture Deep Dive

The app works like a small school office.

SwiftData is the filing cabinet. `Subject`, `Teacher`, `ScheduleLesson`, `Homework`, and `DiaryProfile` are the folders inside it. SwiftUI is the front desk: it shows the right form or list and writes changes back through `ModelContext`.

The schedule does not store just loose strings. A lesson points to a `Subject` and optionally a `Teacher`, but it also keeps fallback subject text and color. That is the app's sticky note system: if someone removes a subject later, an old lesson can still say what it used to be instead of turning into a mystery row.

## The Codebase Map

- `SchoolDiary/DataModel/*.swift` - SwiftData model classes: profile, teachers, subjects, lessons, and homework.
- `SchoolDiary/DataModel/Enums/*.swift` - small domain enums like weekdays and homework status buckets.
- `SchoolDiary/DataModel/SupportingTypes/*.swift` - helper value types such as the subject color palette.
- `SchoolDiary/ContentView.swift` - the three-tab app shell.
- `SchoolDiary/Views/ScheduleView.swift` - the Monday-Friday schedule cockpit: day picker, lesson list, delete, and drag reorder.
- `SchoolDiary/Views/ScheduleLessonRow.swift` - the compact lesson row used in the schedule list.
- `SchoolDiary/Views/LessonDetailView.swift` - one lesson's detail screen plus its recent matching homework.
- `SchoolDiary/Views/LessonEditorView.swift` - the add/edit lesson form, including subject and teacher selection.
- `SchoolDiary/Views/HomeworkView.swift` - homework grouped into active, overdue, no due date, and completed.
- `SchoolDiary/Views/SettingsView.swift` - owner profile plus editable subject and teacher lists.
- `SchoolDiary/SharedViews/DiaryComponents.swift` - small shared UI pieces like color dots and swatches.
- `SchoolDiary/Services/SampleData.swift` - sample records for previews and first launch.

## Tech Stack & Why

SwiftUI is used because this app is mostly lists, forms, pickers, sheets, and navigation. That is SwiftUI's home turf.

SwiftData is used because the diary needs local persistence without a separate database layer. The models are plain Swift classes annotated with `@Model`, which keeps the code close to the domain language: subjects, teachers, lessons, homework.

Color hex strings are stored instead of `Color` because persistence likes simple values. The UI turns those strings back into colored circles when it draws the screen.

## The Journey

### Project Rename

The project started life as `SchookDiary`, a tiny typo with surprisingly long legs. The visible Xcode group, target/product, and app entry file were moved to `SchoolDiary` through Xcode tooling. We avoided direct `project.pbxproj` surgery because doing that while Xcode is open is like changing a tire while the car is moving.

### From Template Item to Real Domain

The default `Item(timestamp:)` model was replaced with the actual diary domain. This is the first major architectural step: the app now speaks school language instead of template language.

### Homework Buckets

Homework has only a simple stored status: active or completed. The richer list sections are computed from status plus due date. That keeps the database honest: \"overdue\" is not a thing you store forever, it is a thing that becomes true when today's date passes the due date.

### The `className` Trap

The owner profile originally stored the school class in a property named `className`. That looked innocent, but SwiftData sits on top of Core Data machinery, and `className` is close enough to the Objective-C/Core Data world that the UI could show `NSManagedObject` instead of the student's actual class. The fix was to rename the stored Swift property to `schoolClassName`, leaving the old name behind entirely so new code avoids the collision.

### Settings Got a Switchboard

Settings used to stack profile, subjects, and teachers in one long list. That works, but it feels like keeping three desk drawers open at once. A segmented `Picker` now acts like a little switchboard at the top: choose `Профіль`, `Предмети`, or `Вчителі`, and the list shows only that workspace. The edit button also appears only where deletion actually makes sense.

### The Teacher Picker Learns to Be Polite

When adding a new lesson, the teacher section used to start at `Без вчителя` even when the diary already had teachers saved. That was technically honest but a little like walking into a classroom and pretending the teacher list on the wall does not exist. The editor now checks the saved teachers on appear: if this is a brand-new lesson and at least one teacher exists, it opens on `Зі списку` and preselects the first teacher.

### Empty Schedule Days Get a Doorbell

An empty schedule day used to say `Додайте уроки для цього дня`, then quietly wait for the user to notice the plus button in the toolbar. That was usable, but it made the empty state feel like a locked classroom with a sign on the door. Now the empty state includes its own `Додати урок` button, wired to the same lesson editor sheet as the toolbar action.

### The Great `Items.swift` Unpacking

`Items.swift` had become a junk drawer: weekdays, homework statuses, section buckets, and color palette data all living together because they were small. Small files can still have different jobs. The file was split into `DataModel/Enums` for the domain vocabulary and `DataModel/SupportingTypes` for helper structs. Now the codebase feels more like a labeled school binder than a pile of loose worksheets.

### The App Gets a Face

The app icon now looks like a school diary instead of a blank template square: a bright notebook, a checklist, and a pencil, all drawn as a clean 1024x1024 asset. Xcode's modern app icon set also supports dark and tinted appearances, so the asset catalog has three matching PNGs wired into `AppIcon.appiconset`. The first generated version had white corners because the gradient did not extend past its start and end points; the fix was to make the gradient draw before and after those points so the whole canvas is covered.

### ScheduleView Goes on a Diet

`ScheduleView.swift` had started doing the job of an entire school hallway: schedule list, row drawing, lesson details, homework mini-rows, and the lesson editor were all squeezed into one file. It worked, but navigating it felt like opening one giant notebook and finding math, history, lunch plans, and permission slips on the same page.

The refactor split the hallway into classrooms. `ScheduleView` now owns the schedule workflow, `ScheduleLessonRow` draws one lesson, `LessonDetailView` handles recent homework for a selected lesson, and `LessonEditorView` owns the add/edit form. The behavior stayed the same, but the mental load dropped: when the editor needs work, you open the editor file instead of spelunking past list swipe actions and homework filtering.

Previews were added beside the split views using `SampleData.preview`, which turns Xcode previews into a tiny rehearsal stage instead of a blank set.

### Pickers Learn to Wait Their Turn

The lesson and homework editors used to grab the first saved subject or teacher as soon as the sheet opened. Convenient? Sometimes. Sneaky? Also yes. A form should not silently decide that the first alphabetic subject is the one the student meant. The subject and teacher dropdowns now start with `Вибрати`, which is the UI equivalent of a polite pause before writing anything into the diary.

### Today's Timetable Gets the Front Desk

The schedule tab now treats "today" as the receptionist who gets first say. When the schedule screen appears for the first time, it selects the current school day; if the calendar says Saturday or Sunday, the app points back to Monday instead of wandering into a weekend with no classes. The `Weekday.currentSchoolDay` helper is the tiny calendar translator doing that job.

The lesson detail screen also grew a shortcut: a plus button for adding homework directly from that lesson. The trick is that homework still belongs to a `Subject`, not to a specific timetable row. So `HomeworkEditorView` now accepts an optional lesson and uses it like a pre-filled hall pass: if the lesson has a saved subject, that subject is selected; if it only has fallback text, the editor starts in "new subject" mode with the lesson name and color already filled in.

### Homework Rows Get Their Toolkit

Lesson details used to show homework like museum labels: useful to read, but hands off. Now each visible homework row is an actual control. Tap it to edit, swipe one way to mark it done or active again, and swipe the other way to edit or delete. The same `HomeworkEditorView` still does the editing, so the lesson page gets more power without growing a second, slightly different homework workflow.

### The Due Date Calendar Reads the Timetable

The homework editor learned a useful school trick: when a subject is selected and a due date is enabled, the calendar checks the schedule and highlights the weekdays where that subject appears. It is like the diary whispering, "Math usually happens on Tuesday and Thursday, maybe pick one of those."

SwiftUI's built-in `DatePicker` is great for plain date selection, but it does not let us decorate individual day cells. So the editor now uses a small custom SwiftUI calendar, fed by the same `ScheduleLesson` data that powers the timetable. The important bit is that the calendar does not invent new rules; it asks the existing schedule which weekdays belong to the selected subject, then paints those dates with the subject color.

### The Calendar Learns to Step Aside

The first custom due date calendar did its job, but it stayed open after a date was chosen and sat a little too low in the homework form. That made the sheet feel like a notebook page where the calendar was hanging off the bottom edge. The fix was behavioral and structural: selecting a day now collapses the calendar, and the due-date controls moved above the big task description field so the calendar opens from a higher, more visible spot.

### The Launch Screen Gets a Proper Greeting

The app used to rely on Xcode's generated launch screen, which is basically the stage curtain: useful, but not very personal. Now `LaunchScreen.storyboard` puts the diary's own face on that first moment, showing the same notebook artwork as the app icon and the Ukrainian title `Мій щоденник`.

The important trick was not to point the storyboard at `AppIcon.appiconset` directly. App icons are special-purpose assets, not general image resources you should lean on from UI. So the icon art was copied into a normal `LaunchIcon.imageset`, like making a clean photocopy for the front desk while leaving the official ID badge in its own holder.

## Engineer's Wisdom

Store facts, compute interpretations. A due date is a fact; overdue is an interpretation.

Keep UI-only types out of persistence. `Color` belongs in SwiftUI; `#3B82F6` belongs in SwiftData.

Make deletion survivable. Optional relationships plus fallback text protect the UI from showing blank rows when related records change.

Split by reason to change, not by line count alone. The schedule screen, row, detail, and editor change for different reasons, so they deserve different files.

Let shortcuts reuse real workflows. The lesson-detail plus button opens the same homework editor as the homework tab, just with better defaults, so the app gains convenience without inventing a second save path.

When a system control will not expose the state you need to style, build the smallest custom control that owns only that missing behavior. The new due date calendar still uses plain SwiftUI buttons and bindings; it just adds schedule-aware day coloring that `DatePicker` cannot provide.

Launch screens are snapshots, not mini apps. Keep them static, resource-backed, and simple enough for iOS to show instantly while the real SwiftUI interface is warming up behind the curtain.

## If I Were Starting Over...

I would name the project `SchoolDiary` before creating the Xcode template, because project renames touch more places than app code. I would also create the `DataModel/Enums` and `DataModel/SupportingTypes` folders from the beginning, because clear homes for tiny types prevent a catch-all file from quietly growing roots.
