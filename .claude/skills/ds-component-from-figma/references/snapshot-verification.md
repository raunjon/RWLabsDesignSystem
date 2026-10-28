# Rendering a component on the simulator

Xcode previews can't be driven from the terminal, and the package has no app or test target. This renders a gallery view to PNGs with a throwaway test target in a **scratch copy** of the package, so the user's `Package.swift` is never touched.

## What doesn't work (and why)

- Hosting the view in a `UIWindow` and calling `drawHierarchy` from a test produces blank white images: a hostless test bundle has no window scene to draw into.
- `ImageRenderer` alone renders dynamic `UIColor`s in light mode only. Wrap it in `UITraitCollection(userInterfaceStyle:).performAsCurrent` **and** set `.environment(\.colorScheme, …)` to get correct dark renders.
- Building with `-scheme RWLabsDesignSystem-Package` fails; the scheme in the copy is `RWLabsDesignSystem`.
- Pass the output folder to the test through the `TEST_RUNNER_` prefix: `TEST_RUNNER_SNAP_DIR=<dir>` reaches the test as `SNAP_DIR`.
- When cleaning old PNGs, spell out the absolute path (or use `"${S:?}"/*.png`); a bare `rm -f $S/*.png` is blocked by the safety check.

## Steps

Use the session's scratchpad directory as `<snap>`.

1. Copy the package:
   ```bash
   mkdir -p <snap>/Tests/SnapTests
   cp -R <repo>/Sources <repo>/Package.swift <snap>/
   ```
2. In `<snap>/Package.swift`, add after the library target:
   ```swift
   .testTarget(name: "SnapTests", dependencies: ["RWLabsDesignSystem"])
   ```
3. Write `<snap>/Tests/SnapTests/Snap.swift`, replacing the gallery body with the component's states (mirror the Figma sheet):
   ```swift
   import XCTest
   import SwiftUI
   @testable import RWLabsDesignSystem

   @MainActor
   final class Snap: XCTestCase {
       func gallery() -> some View {
           VStack(alignment: .leading, spacing: 12) {
               // One group per size, one row per Figma state, plus custom-label examples
           }
           .padding(16)
           .frame(width: 390)
           .background(Color.Background.primary)
       }

       func render(_ theme: any DSTheme, _ scheme: ColorScheme, _ name: String) {
           DesignSystem.configure(theme: theme)
           let style: UIUserInterfaceStyle = scheme == .dark ? .dark : .light
           var img: UIImage?
           UITraitCollection(userInterfaceStyle: style).performAsCurrent {
               let r = ImageRenderer(content: gallery().environment(\.colorScheme, scheme))
               r.scale = 2
               img = r.uiImage
           }
           let out = ProcessInfo.processInfo.environment["SNAP_DIR"] ?? NSTemporaryDirectory()
           try! img!.pngData()!.write(to: URL(fileURLWithPath: out).appendingPathComponent(name + ".png"))
       }

       func testSnap() {
           render(RWLabsTheme(), .light, "rwlabs-light")
           render(RWLabsTheme(), .dark, "rwlabs-dark")
           render(BWTheme(), .light, "bw-light")
           render(BWTheme(), .dark, "bw-dark")
       }
   }
   ```
4. Pick a simulator (`xcrun simctl list devices available | grep iPhone`), boot it, and run:
   ```bash
   xcrun simctl boot <udid>
   cd <snap> && TEST_RUNNER_SNAP_DIR=<snap> xcodebuild test -scheme RWLabsDesignSystem \
     -destination 'id=<udid>' -derivedDataPath <snap>/dd
   ```
5. `Read` each PNG and compare with the Figma screenshot. After editing the real component, copy the changed source file into `<snap>/Sources/…` again before re-running.
6. Send the most useful render to the user with `SendUserFile`.
