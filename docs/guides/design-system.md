# Design System Guide

## Overview

This template includes a foundational design system to ensure UI consistency. All design tokens are centralized in `Shared/DesignSystem/DesignConstants.swift`.

## Using Design Tokens

### Spacing

Consistent spacing throughout your app:

```swift
VStack(spacing: DesignConstants.Spacing.medium) {
    Text("Title")
    Text("Subtitle")
}
.padding(DesignConstants.Spacing.large)
```

Available values:
- `extraSmall` - 4pt (tight spacing)
- `small` - 8pt (compact layouts)
- `medium` - 16pt (default spacing)
- `large` - 24pt (generous spacing)
- `extraLarge` - 32pt (section breaks)
- `huge` - 48pt (major sections)

### Corner Radius

Rounded corners for consistency:

```swift
RoundedRectangle(cornerRadius: DesignConstants.CornerRadius.medium)
    .fill(Color.blue)

// Or on any view
Text("Button")
    .padding()
    .background(Color.blue)
    .cornerRadius(DesignConstants.CornerRadius.small)
```

Available values:
- `small` - 4pt (subtle rounding)
- `medium` - 8pt (default)
- `large` - 12pt (prominent)
- `extraLarge` - 16pt (very rounded)
- `circle` - 9999pt (perfectly circular)

### Typography

Semantic font styles:

```swift
Text("Large Title")
    .font(DesignConstants.Typography.largeTitle)

Text("Body text")
    .font(DesignConstants.Typography.body)

Text("Bold body")
    .font(DesignConstants.Typography.bodyBold)
```

Available styles:
- System sizes: `largeTitle`, `title1`, `title2`, `title3`, `headline`, `body`, `callout`, `subheadline`, `footnote`, `caption`, `caption2`
- Custom weights: `bodyBold`, `headlineLight`

### Shadows

Consistent shadow depth:

```swift
let shadow = DesignConstants.Shadow.medium

Rectangle()
    .shadow(
        color: shadow.color,
        radius: shadow.radius,
        x: shadow.x,
        y: shadow.y
    )
```

Available shadows:
- `small` - Subtle elevation
- `medium` - Default cards
- `large` - Prominent modals

### Icon Sizes

Standard sizes for SF Symbols and icons:

```swift
Image(systemName: "star.fill")
    .font(.system(size: DesignConstants.IconSize.medium))
```

Available sizes:
- `small` - 16pt
- `medium` - 24pt
- `large` - 32pt
- `extraLarge` - 48pt

### Animation Durations

Consistent timing for animations:

```swift
withAnimation(.easeInOut(duration: DesignConstants.Animation.standard)) {
    isExpanded.toggle()
}
```

Available durations:
- `quick` - 0.2s (micro-interactions)
- `standard` - 0.3s (default)
- `slow` - 0.5s (emphasis)
- `verySlow` - 0.8s (dramatic reveals)

### Opacity

Standard transparency levels:

```swift
Button("Disabled") {}
    .opacity(DesignConstants.Opacity.disabled)

Color.black.opacity(DesignConstants.Opacity.overlay)
```

Available values:
- `disabled` - 0.5 (disabled state)
- `subtle` - 0.7 (secondary elements)
- `overlay` - 0.3 (overlays, scrims)

### Border Widths

Standard border thicknesses:

```swift
Rectangle()
    .stroke(lineWidth: DesignConstants.BorderWidth.thin)
```

Available widths:
- `thin` - 1pt (subtle)
- `medium` - 2pt (default)
- `thick` - 3pt (emphasis)

## View Extensions

### Conditional Modifiers

Apply modifiers conditionally:

```swift
Text("Hello")
    .if(isHighlighted) { view in
        view.foregroundStyle(.red)
    }

Text("Status")
    .if(isActive,
        then: { $0.foregroundStyle(.green) },
        else: { $0.foregroundStyle(.gray) })
```

### Layout Helpers

Centering and corner radius:

```swift
Text("Centered")
    .centered(padding: 20)

Rectangle()
    .cornerRadius(12, corners: [.topLeft, .topRight])
```

### Card Style

Quick card styling:

```swift
VStack {
    Text("Card content")
}
.cardStyle()

// Custom styling
.cardStyle(
    backgroundColor: .white,
    cornerRadius: DesignConstants.CornerRadius.large,
    shadowRadius: 8
)
```

### Debug Helpers

Debugging layout issues:

```swift
VStack {
    Text("Debug me")
}
.debugBorder()  // Red border in debug builds only
.debugPrint("VStack appeared")  // Console log in debug builds only
```

## Color Extensions

### Hex Colors

Create colors from hex strings:

```swift
Color(hex: "#FF5733")
Color(hex: "FF5733")
Color(hex: "#80FF5733")  // With alpha
```

Convert to hex:

```swift
let color = Color.blue
let hex = color.toHex()  // "#0000FF" (approximately)
let hexWithAlpha = color.toHex(includeAlpha: true)
```

### Brightness Adjustments

Lighten or darken colors:

```swift
Color.blue.lighter(by: 0.2)  // 20% lighter
Color.blue.darker(by: 0.3)   // 30% darker
```

### Semantic Colors

Adaptive colors that respect light/dark mode:

```swift
Text("Adaptive text")
    .foregroundStyle(Color.adaptiveText)

Text("Secondary")
    .foregroundStyle(Color.adaptiveSecondaryText)

.background(Color.adaptiveBackground)
.background(Color.adaptiveGroupedBackground)  // For grouped lists
```

### Random Colors (Debug)

Generate random colors for debugging layouts:

```swift
Rectangle()
    .fill(Color.random)
```

## Example: Building a Card

Combining design system elements:

```swift
struct ProfileCard: View {
    let name: String
    let role: String
    let isActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DesignConstants.Spacing.small) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: DesignConstants.IconSize.large))
                    .foregroundStyle(Color.adaptiveText)

                VStack(alignment: .leading, spacing: DesignConstants.Spacing.extraSmall) {
                    Text(name)
                        .font(DesignConstants.Typography.headline)

                    Text(role)
                        .font(DesignConstants.Typography.subheadline)
                        .foregroundStyle(Color.adaptiveSecondaryText)
                }

                Spacer()

                Circle()
                    .fill(isActive ? Color.green : Color.gray)
                    .frame(width: 12, height: 12)
            }
        }
        .cardStyle(
            cornerRadius: DesignConstants.CornerRadius.large,
            shadowRadius: DesignConstants.Shadow.medium.radius
        )
        .if(!isActive) { view in
            view.opacity(DesignConstants.Opacity.disabled)
        }
    }
}
```

## Extending the Design System

### Adding Custom Tokens

Add new tokens to `DesignConstants.swift`:

```swift
enum DesignConstants {
    // ... existing tokens ...

    /// App-specific button heights
    enum ButtonHeight {
        static let small: CGFloat = 32
        static let medium: CGFloat = 44
        static let large: CGFloat = 56
    }
}
```

### Adding Custom Extensions

Create new extension files in `Shared/Extensions/`:

```swift
// ButtonExtensions.swift
extension Button {
    func primaryStyle() -> some View {
        self
            .buttonStyle(.borderedProminent)
            .frame(height: DesignConstants.ButtonHeight.medium)
            .cornerRadius(DesignConstants.CornerRadius.medium)
    }
}
```

## Best Practices

1. **Always use tokens** - Avoid hardcoded values
2. **Extend, don't modify** - Add new tokens rather than changing existing ones
3. **Document custom tokens** - Add comments explaining when to use them
4. **Use semantic names** - `errorRed` not `red500`
5. **Test in dark mode** - Use `Color.adaptiveX` for light/dark compatibility
6. **Leverage extensions** - Create reusable modifiers for common patterns

## See Also

- **Architecture Guide** - `docs/guides/architecture.md`
- **Customization Guide** - `docs/guides/customization.md`
