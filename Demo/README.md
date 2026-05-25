# RollingNumbers Demo

Sample multi-platform app demonstrating the SwiftUI `RollingNumbers` library.

## Run the demo

1. Open `RollingNumbersDemo.xcodeproj` in Xcode.
2. Select a destination:
   - **iPhone** or **iPad** Simulator
   - **My Mac**
3. Press **Run** (⌘R).

The demo links to the local Swift package at the repository root (`../..`), so library changes rebuild automatically.

## What the demo includes

- **Rolling display** — large animated number with tap-to-focus input
- **Number input** — type values and watch digits roll
- **Quick actions** — +100, -100, Random, Long, Reset
- **Live configuration** — animation type, direction, alignment, font size, speed, spacing, overflow mode, and currency formatting

## Requirements

- Xcode 15+
- iOS 15.0+ / macOS 12.0+ (demo app; library platform minimums match `Package.swift`)

## Project layout

```
Demo/
└── RollingNumbersDemo/
    ├── RollingNumbersDemo.xcodeproj
    └── RollingNumbersDemo/
        ├── RollingNumbersDemoApp.swift
        ├── ContentView.swift
        └── Assets.xcassets
```
