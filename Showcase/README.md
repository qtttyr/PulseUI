# PulseUI Showcase — PulsePlayground

A marketing-grade, live showcase of all 43 Pulse UI components. Open it in
Xcode (26+) and run it on your phone or the simulator — every card is an
interactive live demo, not a static screenshot.

## Run

```bash
open Showcase/PulsePlayground.xcodeproj
```

Then select the **PulsePlayground** scheme and an iOS 26 simulator or your
device. The project uses a local Swift package reference to the repo root, so
everything is rebuilt from the current source — edit any component and hit
Run to see it immediately.

## What's inside

- Every component from `Sources/PulseUI/Components` gets a live card with its
  own `@State` demo (see `GalleryRootView.swift` + `DemoScenes.swift`).
- Tap a card to open a full-screen detail: a bigger live stage, the ready-to-
  copy usage snippet, and the matching `pulse add <slug>` command from the
  `pulse` CLI.
- Top bar: appearance switcher (light / system / dark) and a **Glass / Solid**
  toggle that flips cards between native Liquid Glass and classic surfaces to
  show off the theme system.
- Theme entry is `PulsePlaygroundApp.swift` — `.pulseTheme(pulse)` with a
  lime-green accent, rounded design tokens and `.pulseToast()` on the root.

## Project file

`PulsePlayground.xcodeproj` is hand-maintained (objectVersion 77, a
`PBXFileSystemSynchronizedRootGroup` for the app sources, and a local Swift
package reference to `../`). New files added under `Showcase/PulsePlayground/`
are picked up automatically.