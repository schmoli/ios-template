# Logging Guide

## Overview

This template uses Apple's unified logging system (`os.log`) with a centralized `AppLogger` wrapper for type-safe, categorized logging.

## Quick Start

```swift
import os.log

private let logger = AppLogger.logger(for: .networking)

func fetchData() {
    logger.info("Starting data fetch")
    logger.debug("Request URL: \(url)")
    logger.error("Failed to fetch: \(error)")
}
```

## Log Categories

Categories help filter and organize logs by functional area:

- `.startup` - App lifecycle and initialization
- `.networking` - API calls, network requests
- `.ui` - User interface events and interactions
- `.data` - Data persistence and processing
- `.auth` - Authentication and authorization
- `.general` - Uncategorized logs

### Adding New Categories

Edit `MyApp/Core/Logging/LogCategory.swift`:

```swift
enum LogCategory: String, Sendable {
    case startup
    case networking
    case myNewCategory  // Add your category
}
```

## Log Levels

### info
General informational messages about app state.

```swift
logger.info("User logged in successfully")
```

### debug
Detailed information useful during development.

```swift
logger.debug("Cache hit for key: \(key)")
```

### error
Error conditions that need attention.

```swift
logger.error("Failed to decode response: \(error)")
```

### fault
Critical failures requiring immediate attention.

```swift
logger.fault("Database corrupted, cannot continue")
```

## Viewing Logs

### Console.app
1. Open Console.app
2. Filter by subsystem: `com.example.MyApp`
3. Filter by category: `networking`, `ui`, etc.

### Xcode Console
Logs appear in Xcode's console when running from Xcode.

### Terminal
```bash
log stream --predicate 'subsystem == "com.example.MyApp"'
```

## Best Practices

### Do:
- Use appropriate log levels (don't log errors as info)
- Use specific categories for better filtering
- Log meaningful events (user actions, state changes, errors)
- Use string interpolation for structured data

### Don't:
- Log sensitive information (passwords, tokens, PII)
- Log in tight loops (performance impact)
- Use print() instead of Logger (logs are lost)
- Mix different concerns in one category

## Customization

When adapting this template, update the subsystem in `MyApp/Core/Logging/AppLogger.swift`:

```swift
static let subsystem = "com.yourcompany.YourApp"
```

## Swift 6 Concurrency

`LogCategory` is marked `Sendable` for safe use across concurrency boundaries:

```swift
Task {
    logger.info("Background task started")
}
```
