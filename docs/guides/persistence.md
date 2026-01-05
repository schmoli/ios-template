# Persistence Guide

The template provides `SwiftDataPersistence` - a protocol-based wrapper around SwiftData for testable, type-safe data storage.

## Quick Start

### 1. Define Your Models

```swift
import SwiftData

@Model
final class TodoItem {
    var title: String
    var isCompleted: Bool
    var createdAt: Date

    init(title: String, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}
```

### 2. Wire Up in App Entry Point

```swift
import SwiftUI
import SwiftData

@main
struct MyAppApp: App {
    let persistence: SwiftDataPersistence

    init() {
        do {
            let schema = Schema([TodoItem.self])
            persistence = try SwiftDataPersistence(schema: schema)
        } catch {
            fatalError("Failed to create persistence: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(persistence.modelContainer)
        }
    }
}
```

### 3. Use in Views

```swift
import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var todos: [TodoItem]

    var body: some View {
        List {
            ForEach(todos) { todo in
                Text(todo.title)
            }
        }
        .toolbar {
            Button("Add") {
                addTodo()
            }
        }
    }

    func addTodo() {
        let todo = TodoItem(title: "New task")
        modelContext.insert(todo)
        try? modelContext.save()
    }
}
```

### 4. Use in View Models

```swift
import SwiftData

@Observable
@MainActor
final class TodoViewModel {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func addTodo(title: String) throws {
        let todo = TodoItem(title: title)
        modelContext.insert(todo)
        try modelContext.save()
    }

    func deleteTodo(_ todo: TodoItem) throws {
        modelContext.delete(todo)
        try modelContext.save()
    }

    func fetchAll() throws -> [TodoItem] {
        let descriptor = FetchDescriptor<TodoItem>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
}
```

## Querying Data

### Basic @Query

```swift
@Query private var todos: [TodoItem]
```

### Sorted Query

```swift
@Query(sort: \.createdAt, order: .reverse)
private var todos: [TodoItem]
```

### Filtered Query

```swift
@Query(filter: #Predicate<TodoItem> { todo in
    !todo.isCompleted
})
private var activeTodos: [TodoItem]
```

### Complex Query

```swift
@Query(
    filter: #Predicate<TodoItem> { todo in
        todo.title.contains("important") && !todo.isCompleted
    },
    sort: \.createdAt,
    order: .reverse
)
private var importantTodos: [TodoItem]
```

## CRUD Operations

### Create

```swift
let todo = TodoItem(title: "Buy groceries")
modelContext.insert(todo)
try modelContext.save()
```

### Read

```swift
// Via @Query in views
@Query private var todos: [TodoItem]

// Via FetchDescriptor
let descriptor = FetchDescriptor<TodoItem>()
let todos = try modelContext.fetch(descriptor)
```

### Update

```swift
todo.title = "Buy groceries and gas"
try modelContext.save()
```

### Delete

```swift
modelContext.delete(todo)
try modelContext.save()
```

## Relationships

### One-to-Many

```swift
@Model
final class TodoList {
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \TodoItem.list)
    var items: [TodoItem] = []

    init(name: String) {
        self.name = name
    }
}

@Model
final class TodoItem {
    var title: String
    var list: TodoList?

    init(title: String) {
        self.title = title
    }
}
```

### Many-to-Many

```swift
@Model
final class Tag {
    var name: String
    var items: [TodoItem] = []

    init(name: String) {
        self.name = name
    }
}

@Model
final class TodoItem {
    var title: String
    var tags: [Tag] = []

    init(title: String) {
        self.title = title
    }
}
```

## Architecture

- **`PersistenceProtocol`** - Protocol defining storage contract
- **`SwiftDataPersistence`** - Production implementation wrapping ModelContainer
- **`MockPersistence`** - In-memory mock for testing
- **`PersistenceError`** - Structured error types

All types are `Sendable` and thread-safe (actor-isolated where needed).

## Testing

Use `MockPersistence` with in-memory container:

```swift
import Testing
import SwiftData

@Test func testTodoCreation() async throws {
    // Create in-memory persistence
    let schema = Schema([TodoItem.self])
    let mock = try MockPersistence(schema: schema)

    // Get context
    let context = mock.modelContainer.mainContext

    // Test operations
    let todo = TodoItem(title: "Test task")
    context.insert(todo)
    try context.save()

    // Verify
    let descriptor = FetchDescriptor<TodoItem>()
    let todos = try context.fetch(descriptor)
    #expect(todos.count == 1)
    #expect(todos[0].title == "Test task")
}

@Test func testTodoCompletion() async throws {
    let mock = try MockPersistence(schema: Schema([TodoItem.self]))
    let context = mock.modelContainer.mainContext

    let todo = TodoItem(title: "Test")
    context.insert(todo)
    try context.save()

    // Complete todo
    todo.isCompleted = true
    try context.save()

    // Verify
    let descriptor = FetchDescriptor<TodoItem>()
    let todos = try context.fetch(descriptor)
    #expect(todos[0].isCompleted == true)
}
```

## Migration

SwiftData handles schema migration automatically for simple changes:
- Adding optional properties
- Adding relationships
- Renaming properties (with `@Attribute(.originalName)`)

### Example Migration

```swift
// V1
@Model
final class TodoItem {
    var title: String
}

// V2 - Add optional property (automatic)
@Model
final class TodoItem {
    var title: String
    var notes: String?  // Automatically migrated
}

// V3 - Rename (requires attribute)
@Model
final class TodoItem {
    @Attribute(.originalName("title"))
    var name: String
    var notes: String?
}
```

## Error Handling

```swift
do {
    try modelContext.save()
} catch let error as PersistenceError {
    switch error {
    case .saveFailed(let underlying):
        print("Save failed: \(underlying)")
    case .fetchFailed(let underlying):
        print("Fetch failed: \(underlying)")
    case .deleteFailed(let underlying):
        print("Delete failed: \(underlying)")
    case .containerCreationFailed(let underlying):
        print("Container creation failed: \(underlying)")
    }
}
```

## Best Practices

### Do:
- Define models in dedicated files
- Use `@MainActor` for view models using ModelContext
- Use `@Query` in views for automatic updates
- Use relationships instead of manual IDs
- Save after batches of changes, not each change
- Use `FetchDescriptor` for programmatic queries

### Don't:
- Pass ModelContext across async boundaries
- Fetch in tight loops (use @Query)
- Store large binary data (>1MB) - use file URLs instead
- Forget cascade delete rules for relationships
- Mix CoreData and SwiftData

## Performance Tips

### Batch Operations

```swift
// Good
for item in itemsToAdd {
    modelContext.insert(item)
}
try modelContext.save()  // One save

// Avoid
for item in itemsToAdd {
    modelContext.insert(item)
    try modelContext.save()  // Save per item (slow)
}
```

### Limit Fetches

```swift
let descriptor = FetchDescriptor<TodoItem>(
    predicate: #Predicate { !$0.isCompleted },
    sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
)
descriptor.fetchLimit = 20
let recent = try modelContext.fetch(descriptor)
```

### Lazy Relationships

```swift
@Model
final class TodoList {
    var name: String

    // Only loads when accessed
    @Relationship(deleteRule: .cascade)
    var items: [TodoItem] = []
}
```

## Example: Complete Feature

```swift
import SwiftUI
import SwiftData

@Model
final class Note {
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date

    init(title: String, content: String = "") {
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

@Observable
@MainActor
final class NotesViewModel {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func createNote(title: String) throws {
        let note = Note(title: title)
        modelContext.insert(note)
        try modelContext.save()
    }

    func updateNote(_ note: Note, title: String, content: String) throws {
        note.title = title
        note.content = content
        note.updatedAt = Date()
        try modelContext.save()
    }

    func deleteNote(_ note: Note) throws {
        modelContext.delete(note)
        try modelContext.save()
    }

    func fetchRecent(limit: Int = 10) throws -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor)
    }
}

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \.updatedAt, order: .reverse) private var notes: [Note]
    @State private var viewModel: NotesViewModel?

    var body: some View {
        List {
            ForEach(notes) { note in
                NavigationLink(value: note) {
                    VStack(alignment: .leading) {
                        Text(note.title)
                            .font(.headline)
                        Text(note.content)
                            .font(.subheadline)
                            .lineLimit(2)
                    }
                }
            }
            .onDelete(perform: deleteNotes)
        }
        .toolbar {
            Button("New Note") {
                try? viewModel?.createNote(title: "Untitled")
            }
        }
        .onAppear {
            viewModel = NotesViewModel(modelContext: modelContext)
        }
    }

    func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            try? viewModel?.deleteNote(notes[index])
        }
    }
}
```

## See Also

- **Architecture** - `docs/guides/architecture.md` - Overall app structure
- **Testing** - `docs/guides/testing.md` - Testing strategies
- **Lifecycle** - `docs/guides/lifecycle.md` - Saving state on background
