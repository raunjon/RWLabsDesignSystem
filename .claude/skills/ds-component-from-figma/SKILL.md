---
name: ds-component-from-figma
description: Build or refactor a SwiftUI component in RWLabsDesignSystem from a Figma component (buttons, inputs, pills, cards, toggles, chips…). Use this whenever the user shares a figma.com link to a component or component set, says "implement/refactor this component from Figma", "match the Figma for DSX", "add variants/sizes/states from the design", or asks to restyle an existing DS component to the PlusOne design — even if they don't say "skill" or name every step.
---

# Design-system component from Figma

This is how components in RWLabsDesignSystem get built from the PlusOne Figma file. The goal is a component that matches Figma in every variant and state, reads all values from the theme (so RWLabs, BW and any app theme work), and leaves the caller in control of content.

The workflow came out of refactoring `DSButton`; `Sources/RWLabsDesignSystem/DesignSystem/Components/DSButton.swift` is the reference implementation to imitate.

## 1. Read the design

Figma has two connections in this environment. If one answers "you don't have edit access", use the other (the one whose tools are named `mcp__<uuid>__…`) — it reads the PlusOne file fine.

1. `get_metadata` on the node. Component sets list their variants as symbols named `Property=Value, …` (e.g. `State=Primary, Size=Large`). This is the cheapest way to learn the full variant matrix.
2. Load the design-to-code guidance before `get_design_context` (via `ReadMcpResourceTool`, server `figma`, uri `skill://figma/figma-design-to-code/SKILL.md`), then call `get_design_context` on the **component set** node, not one variant, so you get every variant's values in one response plus a screenshot.
3. `get_variable_defs` on the same node to see which tokens the design uses (`Primary/primary-200`, `Radius/radius-md`, `Body/Regular/14px`…).

Write down, per variant × size: fill, label color, border, height, horizontal/vertical padding, corner radius, gap, text style, icon size. Treat the screenshot as the visual target.

## 2. Read the existing code before designing anything

- The current component file, and every call site: `grep -rn "DSX(\|DSXVariant\|\.X\." Sources`. Note `grep` here is ugrep and zsh doesn't word-split variables, so for bulk edits prefer a small Python script over `xargs`/`$files`.
- The Foundation it must use:
  - Colors: `Foundation/Colors/` — palette scales (`palette.primary.shade200`, `.base` = 500) and role groups in `DSRoleColors.swift`, exposed as `Color.Text.*`, `Color.Button.*` etc. in `Color+DesignSystem.swift`.
  - Spacing/radius: `Foundation/Spacing.swift` (`.xs`, `.s20`, `.radiusMD`…; radius names match Figma's xs/sm/md/lg/xl).
  - Typography: `Foundation/Typography.swift` — `DSTypography.Style` names match Figma (`heading1…3`, `bodyMedium`, `body`, `bodySmallMedium`, `bodySmall`, `label`), applied with `.fontStyle(_:)`.
  - Themes: `Themes/RWLabsTheme.swift`, `Themes/BWTheme.swift`, `Themes/DefaultTheme.swift`.

## 3. Map Figma onto the code

**States are not variants.** Figma often draws interaction states as variants (`State=Pressed`, `State=Disabled`). In SwiftUI these come from the environment: implement them inside a `ButtonStyle`/`ToggleStyle` via `configuration.isPressed` and `@Environment(\.isEnabled)`, so `.disabled(true)` and touches just work. Only real visual families (Primary / Secondary / Tertiary…) become variant enum cases.

**No hex values or raw numbers in components.** Every color goes through a role:

- If the component needs colors the role group doesn't have, add them to its protocol in `DSRoleColors.swift` with a default mapping onto palette scales (e.g. `primaryPressed → palette.secondary.base`, `disabled → palette.primary.shade200`), then add matching accessors to `Color+DesignSystem.swift`.
- Map by scale step, not by hex: find which `Primary/primary-200`, `Neutral/neutral-700`… variable Figma used and use that step. Because the dark scales are inverted, the same step works in dark mode.
- Where Figma uses plain white/black (`#FFFFFF`, `#1A1A1A`), prefer an adaptive equivalent (`Color(light: palette.white, dark: palette.neutral.shade50)`, `neutral.shade900`) and say so.
- Check `BWTheme.swift`: BW's brand fill inverts between black and white, so any label that defaults to fixed white needs a BW override (see `BWButtonColors`). Update or delete overrides whose meaning changed.

Sizes: model them as an enum (`large/medium/small/tiny`) whose properties return tokens — height, horizontal padding, corner radius, text style, icon size, spacing. Use Figma's fixed widths as `minWidth` and full-width layouts as `maxWidth: .infinity`.

## 4. API shape: style the native control, let the caller own the content

The user wants flexibility over generated content. The primary API is a style plus view-modifier helpers on the native control:

```swift
Button { submit() } label: {
    HStack { Image(systemName: "heart.fill"); Text("Continue") }
}
.primaryButtonStyle()                 // also secondary…, tertiary…, size: .small
```

- Public `DSXStyle: ButtonStyle` (or the matching SwiftUI style protocol) taking `variant` and `size`.
- `public extension View` with `dsXStyle(_ variant:, size:)` and one `<variant>XStyle(size:)` helper per variant.
- The style sets defaults only: `.fontStyle(size.fontStyle)` (an inner `.font` still wins), foreground color, fill, border, shape. Use `minHeight`, not a fixed height, and no `lineLimit`, so multi-line or custom labels grow instead of clipping.
- A convenience wrapper (`DSButton(title:icon:…)`) is optional and must be built on the same style. Keep it if components already use it.

## 5. Renames and migration

- Keep old names compiling with `@available(*, deprecated, renamed: "new")` static aliases, then migrate call sites.
- Let the compiler find them: build, capture `warning: 'x' is deprecated: renamed to 'y'` lines with `file:line:col`, and patch those exact columns. Skip paths that aren't real files (`@__swiftmacro_…` are `#Preview` expansions; they disappear once the source is fixed).
- A name reused with a different meaning (old `.secondary` = dark brand fill, new `.secondary` = gray) produces no warning. Find those with grep, decide each one, and list them for the user as visual changes.

## 6. Previews that actually show the theme

`PreviewProvider.init()` is never called, so setting the theme there does nothing. Use one `#Preview` per theme × appearance:

```swift
#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return XGallery().designSystem()
}
#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return XGallery().designSystem().preferredColorScheme(.dark)
}
```

Make the gallery mirror the Figma sheet (one group per size, one row per state) plus a few custom-label examples using the style helpers.

## 7. Build and verify

- Build: `xcodebuild -scheme RWLabsDesignSystem -destination 'generic/platform=iOS Simulator' -derivedDataPath <scratchpad>/dd build`. Red SourceKit diagnostics about macOS availability, `UIColor`, or "Cannot find type" are usually stale indexing for macOS; trust the iOS build.
- Render it: Xcode previews can't be driven from here, so render the gallery to PNGs on the simulator with a throwaway test target in a scratch copy of the package. Follow `references/snapshot-verification.md`. Look at the images next to the Figma screenshot, light and dark, RWLabs and BW, and fix mismatches before reporting.
- Send the user the render.

## 8. Working alongside the user

The user edits files while you work (adds previews, moves files into new folders). Before writing a file you read earlier, re-read or diff it, keep their changes, and mention anything that looks unintended (e.g. a "Dark" preview missing `.preferredColorScheme(.dark)`) instead of silently fixing it.

## 9. Report

Say what matches Figma and how you checked (which renders). Then list:
- API changes and new helpers, with a short usage snippet.
- Visual changes to existing call sites, especially same-name-different-meaning cases.
- Anything from Figma you approximated (white → adaptive surface, icon slot vs. baked-in asset) and dark-mode results that may need a design decision.
