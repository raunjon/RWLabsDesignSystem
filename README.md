# RWLabsDesignSystem

A themeable SwiftUI design system for RWLabs apps, built from the **PlusOne** Figma file. It ships design tokens (color, typography, spacing, radius, shadow), 50+ components, and a theming layer that lets an app swap its whole look — brand colors, fonts, light/dark — without touching component code.

- **Swift Package**, SwiftUI only
- **iOS 18+** (Swift tools 6.2)
- **Depends on [RWLabsFoundation](https://github.com/raunjon/RWLabsFoundation)**, which it re-exports, so `import RWLabsDesignSystem` also brings in its formatting and SwiftUI helpers
- **Light & dark mode** for every token, with an app-wide Light / Dark / System preference
- **Three themes included**: `RWLabsTheme`, `BWTheme`, `DefaultTheme` — or bring your own

---

## Contents

- [Installation](#installation)
- [Quick start](#quick-start)
- [Architecture](#architecture)
- [Theming](#theming)
  - [Built-in themes](#built-in-themes)
  - [Color system](#color-system)
  - [Writing your own palette](#writing-your-own-palette)
  - [Overriding role colors](#overriding-role-colors)
  - [Typography](#typography)
  - [Light / dark preference](#light--dark-preference)
- [Tokens](#tokens)
- [Components](#components)
- [Usage examples](#usage-examples)
- [Project layout](#project-layout)
- [Contributing](#contributing)

---

## Installation

### Xcode

**File → Add Package Dependencies…** and enter the repository URL:

```
https://github.com/raunjon/RWLabsDesignSystem
```

Add the `RWLabsDesignSystem` library to your app target.

### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/raunjon/RWLabsDesignSystem", branch: "master")
],
targets: [
    .target(
        name: "MyApp",
        dependencies: ["RWLabsDesignSystem"]
    )
]
```

For local development alongside an app, use a path dependency instead:

```swift
.package(path: "../RWLabsDesignSystem")
```

---

## Quick start

1. Configure a theme once at launch.
2. Attach `.designSystem()` at the root of your view hierarchy.
3. Use components and tokens.

```swift
import SwiftUI
import RWLabsDesignSystem

@main
struct MyApp: App {
    init() {
        DesignSystem.configure(theme: RWLabsTheme())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .designSystem()
        }
    }
}

struct ContentView: View {
    @State private var email = ""

    var body: some View {
        VStack(alignment: .leading, spacing: .lg) {
            DSText("Welcome back", style: .heading2)

            DSInputField(title: "Email", helper: "We'll never share it") {
                TextField("you@example.com", text: $email)
            }

            DSButton(title: "Continue") { /* … */ }
        }
        .padding(.md)
        .background(Color.Background.primary)
    }
}
```

`.designSystem()` does two things:

- **Rebuilds the view tree when the theme changes.** Components read colors and fonts statically, so switching themes at runtime re-renders everything. Note this resets any `@State` below the modifier.
- **Applies the user's Light / Dark / System preference** from `DSColorSchemeManager`.

If you never call `DesignSystem.configure`, `DefaultTheme` is used — placeholder colors generated from system colors, meant for previews and tests only.

---

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│ App                                                      │
│   DesignSystem.configure(theme: …)   .designSystem()     │
└───────────────┬──────────────────────────────────────────┘
                │
┌───────────────▼──────────────────────────────────────────┐
│ DSTheme                                                  │
│   colors:     DSColorPalette    (7 scales × 50–900)      │
│   typography: DSTypographyScale (font + metrics)         │
└───────────────┬──────────────────────────────────────────┘
                │ derived
┌───────────────▼──────────────────────────────────────────┐
│ Role colors (DSRoleColors)                               │
│   text, background, border, button, input, pill, chat …  │
│   exposed as Color.Text.primary, Color.Button.primary …  │
└───────────────┬──────────────────────────────────────────┘
                │ consumed by
┌───────────────▼──────────────────────────────────────────┐
│ Components (DSButton, DSInputField, DSCard, …)           │
│   never use hex values or raw numbers directly           │
└──────────────────────────────────────────────────────────┘
```

The rule that makes theming work: **components only read role colors and tokens**. A theme supplies seven color scales; every role (button fill, input border, chat bubble…) is derived from those scales by a default mapping, and any role can be overridden per theme.

---

## Theming

### Built-in themes

| Theme | Colors | Font | Notes |
|---|---|---|---|
| `RWLabsTheme` | PlusOne brand palette (coral primary, berry secondary, slate neutral) with hand-tuned dark scales | Inter (falls back to system until bundled) | The production look. Intended to move into the app eventually. |
| `BWTheme` | Grayscale ramps that invert in dark mode; error stays red | System | Brand fills are black on white in light, white on black in dark. Useful for checking components don't rely on color alone. |
| `DefaultTheme` | `DSFallbackColorPalette` — generated from system colors | System | Used until `configure` is called. Previews/tests only. |

Switch at any time:

```swift
DesignSystem.configure(theme: BWTheme())

// Or change just one half of the current theme
DesignSystem.configure(colors: MyColors())
DesignSystem.configure(typography: DSCustomFontTypography(family: "Inter"))
```

Read the active theme with `DesignSystem.theme`.

### Color system

A palette is seven **color families**, each a 10-step scale:

| Family | Typical use |
|---|---|
| `primary` | Brand fills, CTAs, selection |
| `secondary` | Pressed states, accents |
| `neutral` | Text, surfaces, borders |
| `success` / `warning` / `error` / `info` | Status and validation |

Each scale exposes `shade50` … `shade900`, with `base` = `shade500`.

Scale types:

- **`DSStaticColorScale`** — ten fixed colors.
- **`DSAdaptiveColorScale(light:dark:)`** — different scales per appearance. Dark scales are typically the light scale inverted, so the *same step* reads correctly in both modes.
- **`DSGeneratedColorScale(base:)`** — derives all ten steps from a single color. Handy for prototypes.

From the families, the palette derives **role groups**. Components use these through `Color` namespaces:

```swift
Color.Text.primary          Color.Background.primary     Color.Border.focused
Color.Button.primary        Color.Input.placeholder      Color.Icon.brand
Color.Semantic.error        Color.Chat.bar               // …and more
```

Need a raw step? `Color.palette.primary.shade300`.

Role groups available: `text`, `background`, `border`, `button`, `icon`, `input`, `progress`, `selection`, `pill`, `badge`, `swipe`, `search`, `popup`, `card`, `tab`, `navBar`, `chat`. Their default mappings live in [`DSRoleColors.swift`](Sources/RWLabsDesignSystem/DesignSystem/Foundation/Colors/DSRoleColors.swift).

### Writing your own palette

Conform to `DSColorPalette` and provide the seven scales. Everything else has defaults.

```swift
struct AppColors: DSColorPalette {
    let primary: any DSColorScale = DSAdaptiveColorScale(
        light: DSStaticColorScale(
            shade50:  Color(hex: "FEF0F1"), shade100: Color(hex: "FDD8DB"),
            shade200: Color(hex: "FABFC4"), shade300: Color(hex: "F79AA1"),
            shade400: Color(hex: "F37480"), shade500: Color(hex: "EF505F"),
            shade600: Color(hex: "D93D4C"), shade700: Color(hex: "B82C3A"),
            shade800: Color(hex: "8F1E29"), shade900: Color(hex: "631219")
        ),
        dark: DSStaticColorScale(/* inverted ramp */)
    )
    let secondary: any DSColorScale = DSGeneratedColorScale(base: .purple)
    let neutral:   any DSColorScale = DSGeneratedColorScale(base: .gray)
    let success:   any DSColorScale = DSGeneratedColorScale(base: .green)
    let warning:   any DSColorScale = DSGeneratedColorScale(base: .orange)
    let error:     any DSColorScale = DSGeneratedColorScale(base: .red)
    let info:      any DSColorScale = DSGeneratedColorScale(base: .blue)
}

DesignSystem.configure(colors: AppColors())
```

See [`RWLabsTheme.swift`](Sources/RWLabsDesignSystem/Themes/RWLabsTheme.swift) for a compact helper that builds adaptive scales from arrays of hex strings.

### Overriding role colors

When the default mapping doesn't suit a palette, return your own conformance for that role group and override only what differs. `BWTheme` does this because its brand fill flips between black and white:

```swift
struct BWButtonColors: DSButtonColors {
    let palette: any DSColorPalette

    // Default is fixed white; BW's primary fill is white in dark mode, so follow the surface.
    var primaryText:  Color { palette.neutral.shade50 }
    var disabledText: Color { palette.neutral.shade500 }
}

public struct BWColor: DSColorPalette {
    // …scales…
    public var button: any DSButtonColors { BWButtonColors(palette: self) }
}
```

Every other property of `DSButtonColors` keeps its default.

### Typography

The type scale matches Figma's text styles:

| Style | Size / weight | Line height |
|---|---|---|
| `.heading1` | 40 semibold | 48 |
| `.heading2` | 24 semibold | 25 |
| `.heading3` | 20 semibold | 20 |
| `.bodyMedium` | 16 medium | 25 |
| `.body` | 16 regular | 24 |
| `.bodySmallMedium` | 14 medium | 20 |
| `.bodySmall` | 14 regular | 22 |
| `.label` | 12 regular | 20 |
| `.labelMedium` | 12 semibold | 20 |
| `.caption` | 10 regular | 20 |

All styles use −0.15 letter spacing by default.

Apply them:

```swift
Text("Title").typography(.heading2)                      // font, spacing, line height + default color
Text("Title").typography(.heading2, color: .Text.brand)  // custom color
Text("Body").fontStyle(.body)                            // font, spacing, line height only
DSText("Hello", style: .bodySmall, color: .Text.secondary)
```

**Changing the font.** Use `DSCustomFontTypography(family:)` for a bundled family. It resolves PostScript names as `<Family>-<Weight>` (e.g. `Inter-SemiBold`) and falls back to the system font if a face is missing:

```swift
DesignSystem.configure(typography: DSCustomFontTypography(family: "Inter"))
```

Remember to bundle the font files in your app and register them under `UIAppFonts` in Info.plist.

For full control, conform to `DSTypographyScale` and implement `uiFont(size:weight:)` and/or `metrics(for:)`. Both have defaults (system font, Figma metrics).

### Light / dark preference

`DSColorSchemeManager.shared` stores the user's choice (`.light`, `.dark`, `.system`) in `UserDefaults` and `.designSystem()` applies it app-wide. Drop in the ready-made picker:

```swift
DSColorSchemePicker()
```

or set it directly:

```swift
DSColorSchemeManager.shared.setScheme(.dark)
```

---

## Tokens

All tokens are available as `CGFloat` shorthands, so they work anywhere a number does: `.padding(.md)`, `VStack(spacing: .xs)`.

### Spacing

| Token | Value | | Token | Value |
|---|---|---|---|---|
| `.xxs` | 4 | | `.lg` | 24 |
| `.xs` | 8 | | `.xl` | 32 |
| `.sm` | 12 | | `.xxl` | 48 |
| `.md` | 16 | | `.xxxl` | 64 |

A numeric scale is also available — `.s0`, `.s4`, `.s8`, `.s12`, `.s16`, `.s18`, `.s20`, `.s24`, `.s32`, `.s40`, `.s48`, `.s56`, `.s64`, `.s80`, `.s96`, `.s128` — for values the named scale doesn't cover.

Layout helpers: `DSSpacing.Layout.screenMargin` (16), `.sectionSpacing` (24), `.itemSpacing` (16), `.minTouchTarget` (44).

### Radius

Names match Figma's radius scale.

| Token | Value | Figma |
|---|---|---|
| `.radiusNone` | 0 | none |
| `.radiusXS` | 4 | xs |
| `.radiusSM` | 8 | sm |
| `.radiusMD` | 12 | md |
| `.radiusLG` | 16 | lg |
| `.radiusXL` | 20 | xl |
| `.radiusXXL` | 24 | 2xl |
| `.radiusXXXL` | 32 | 3xl |
| `.radiusFull` | 999 | full |

### Border width

`.thin` (1), `.medium` (2), `.thick` (3). There is also a convenience modifier:

```swift
view.border(.Border.subtle, lineWidth: .thin, cornerRadius: .radiusMD)
```

### Shadows

`DSShadow.sm`, `.md`, `.lg`, `.none`, applied with `.shadow(_:)`:

```swift
card.shadow(.md)
```

---

## Components

Every component lives in [`Sources/RWLabsDesignSystem/DesignSystem/Components`](Sources/RWLabsDesignSystem/DesignSystem/Components) and ships with `#Preview`s for each built-in theme in light and dark mode — open the file in Xcode to browse variants.

[`Docs/ComponentInventory.md`](Docs/ComponentInventory.md) tracks which components match Figma, which still need building, and which exist only in code.

### Actions

| Component | Description |
|---|---|
| `DSButton` / `.dsButtonStyle(_:size:)` | CTA button. Variants: `primary`, `secondary`, `tertiary`, `destructive`, `inverse`, `ghost`. Sizes: `large` (56, full width), `medium` (46), `small` (38), `tiny` (36). Loading, disabled, leading/trailing icon. |
| `DSIconButton` | Icon-only button using the same variants. |
| `DSSliderButton` | Swipe-to-confirm button. |
| `DSMenu`, `DSOptionDropdown` | Option dropdown menu. |
| `DSActionSheet` | Bottom action sheet. |

### Inputs

| Component | Description |
|---|---|
| `DSInputField` / `.inputFieldStyle(…)` | Title + styled field + helper. Sizes `large`/`small`; status `normal`, `error`, `autofill`. Wraps any content. |
| `DSTextField` | Ready-made text field on the input style. |
| `DSMobileInputField` | Phone number with country code. |
| `DSOTPTextField` | One-time-code boxes with error state. |
| `DSDateOfBirthTextField`, `DSDatePicker` | Date entry. |
| `DSSearchBar`, `DSSearchBarWithFilters` | Search field, optionally with filter button. |
| `DSPicker`, `DSOptionalPicker`, `DSBasePicker`, `DSModalPicker` | Dropdown / modal pickers. |
| `DSWheelPicker`, `DSHeightPicker`, `DSHeightUnitToggle` | Wheel picker and the cm / ft height picker. |
| `DSInputModalView`, `DSCustomInputModalView` | Modal text entry. |
| `DSChatInput` | Chat composer with voice-recording states (`DSVoiceWaveform`). |

### Selection

| Component | Description |
|---|---|
| `DSChip` / `.pillStyle(size:)` | Pill toggle (`large`, `compact`). |
| `DSInfoPill` | Read-only tag. |
| `DSPillToggle` | Two-option pill switch. |
| `DSSelectionCard` / `DSSelectionCardStyle` | Large tappable option cards, single or multi select. |
| `DSSegmentedControl` | Tab-style segmented control. |
| `DSCheckbox`, `DSCheckboxGroup` | Checkboxes. |
| `DSRadio`, `DSRadioGroup` | Radio buttons. |
| `DSToggle`, `DSToggleGroup` | Switches. |
| `DSSlider`, `DSRangeSlider` | Single and range sliders. |
| `DSStepper` | Increment / decrement. |
| `DSColorSchemePicker` | Light / Dark / System picker. |

### Feedback & status

| Component | Description |
|---|---|
| `DSToast` / `.toast(…)` | Auto-dismissing toast: `success`, `error`, `warning`, `info`. |
| `DSAlert`, `DSBanner` | Inline alerts and banners. |
| `DSPopupCard` / `.dsPopup(…)` | Centered modal card over a dimmed page (app supplies illustration and copy). |
| `DSTooltip` | Tooltip. |
| `DSStepProgress`, `DSProgressBar` | Segmented and linear progress. |
| `DSProgressCircle` | Circular spinner. |
| `DSDotsLoader` | Three-dot loader. |
| `DSSkeleton` | Loading placeholders. |
| `DSEmptyState` | Empty-state screen. |
| `DSBadge`, `DSLabelBadge`, `DSRecommendedBadge` | Count/dot badges, verification labels, animated "Recommended" badge. |

### Content & layout

| Component | Description |
|---|---|
| `DSText` | Text with a typography style and color. |
| `DSCard`, `DSCardContainer`, `DSContentCard`, `DSInfoCard` | Cards; `DSCardContainer` adds the Figma ＋ / added-check affordance. |
| `DSListRow`, `DSListSection` | Settings-style list rows. |
| `DSDivider` | Divider. |
| `DSAvatar`, `DSAvatarGroup` | Avatars and stacked groups. |

### Navigation

| Component | Description |
|---|---|
| `.dsTabBarStyle(selection:tabs:)` + `.dsTab(_:)` | Replaces a native `TabView`'s bar with the Figma nav bar. |
| `DSTabBar`, `DSTabBarView` | Standalone tab bar / container. |

### Chat

| Component | Description |
|---|---|
| `DSChatView`, `DSGroupChatView` | Full chat screen (online/offline header, date pills). |
| `DSChatHeader`, `DSChatDatePill` | Chat screen pieces. |
| `DSChatBubble`, `DSChatReactions`, `DSChatAvatar` | Sender / receiver messages. |
| `DSChatListRow`, `DSUnreadBadge` | Inbox rows (direct / community, read / unread). |

---

## Usage examples

### Buttons

```swift
DSButton(title: "Continue") { next() }

DSButton(title: "Delete account", variant: .destructive, size: .medium) { delete() }

DSButton(title: "Saving", isLoading: true) {}

DSButton(title: "Share", variant: .tertiary, icon: Image(systemName: "square.and.arrow.up"),
         iconPlacement: .leading) { share() }

// Style any Button — pressed and disabled states come from the environment
Button("Skip") { skip() }
    .dsButtonStyle(.ghost, size: .small)
    .disabled(!canSkip)
```

### Input fields

```swift
@FocusState private var focused: Bool

DSInputField(
    title: "Email",
    helper: emailError,
    status: emailError == nil ? .normal : .error,
    isFocused: focused
) {
    TextField("you@example.com", text: $email)
        .focused($focused)
}

// Or style any row as an input
HStack {
    Image(systemName: "lock")
    SecureField("Password", text: $password)
}
.inputFieldStyle(size: .small)
```

### Pills

```swift
Toggle("Hiking", isOn: $likesHiking)
    .pillStyle()

Toggle("Weekends", isOn: $weekends)
    .pillStyle(size: .compact)

DSInfoPill("Verified")
```

### Toasts and popups

```swift
content
    .toast(isShowing: $showSaved, type: .success, title: "Saved", message: "Profile updated")

content
    .dsPopup(isPresented: $showCameraPrompt) {
        DSPopupCard(
            title: "Camera access needed",
            message: "We need access to your camera to take verification photos.",
            primaryAction: DSPopupAction("Allow access") { openSettings() },
            secondaryAction: DSPopupAction("Not now", variant: .ghost) { showCameraPrompt = false }
        ) {
            Image("camera-illustration")
        }
    }
```

### Tab bar

```swift
enum Tab { case home, chat, profile }
@State private var tab: Tab = .home

TabView(selection: $tab) {
    HomeView().dsTab(Tab.home)
    ChatView().dsTab(Tab.chat)
    ProfileView().dsTab(Tab.profile)
}
.dsTabBarStyle(selection: $tab, tabs: [
    DSTab(.home,    title: "Home",    icon: Image("home")),
    DSTab(.chat,    title: "Chat",    icon: Image("chat"), badge: 3),
    DSTab(.profile, title: "Profile", icon: Image("profile")),
])
```

### Using tokens in your own views

```swift
VStack(alignment: .leading, spacing: .xs) {
    Text("Upcoming").typography(.heading3)
    Text("3 events this week").typography(.bodySmall, color: .Text.secondary)
}
.padding(.md)
.background(Color.Background.secondary)
.clipShape(RoundedRectangle(cornerRadius: .radiusLG))
.shadow(.sm)
```

---

## Project layout

```
RWLabsDesignSystem/
├── Package.swift
├── Docs/
│   └── ComponentInventory.md        # Figma ↔ code status for every component
├── .claude/skills/
│   └── ds-component-from-figma/     # Workflow for building components from Figma
└── Sources/RWLabsDesignSystem/
    ├── Themes/
    │   ├── RWLabsTheme.swift        # PlusOne brand palette + Inter
    │   ├── BWTheme.swift            # Black & white palette with role overrides
    │   └── DefaultTheme.swift       # Placeholder used before configure()
    └── DesignSystem/
        ├── Configuration/
        │   └── ColorSchemeManager.swift   # Light / Dark / System preference
        ├── Foundation/
        │   ├── Theme.swift                # DSTheme, DesignSystem, .designSystem()
        │   ├── Typography.swift           # Type scale, DSTypographyScale
        │   ├── Spacing.swift              # Spacing, radius, border, shadow tokens
        │   └── Colors/
        │       ├── DSColorScale.swift     # Static / adaptive / generated scales
        │       ├── DSColorPalette.swift   # Palette protocol + fallback palette
        │       ├── DSRoleColors.swift     # Role groups and default mappings
        │       ├── Color+DesignSystem.swift  # Color.Text.*, Color.Button.* …
        │       └── Color+Hex.swift
        └── Components/                    # DS* components
```

---

## Contributing

### Adding or updating a component

Components are built to match the PlusOne Figma file. The full workflow is in [`.claude/skills/ds-component-from-figma/SKILL.md`](.claude/skills/ds-component-from-figma/SKILL.md); [`DSButton.swift`](Sources/RWLabsDesignSystem/DesignSystem/Components/DSButton.swift) is the reference implementation. The short version:

1. **Read the design** — every variant × size: fill, label, border, height, padding, radius, gap, text style.
2. **Model visual families as variants, not states.** Pressed / disabled come from `ButtonStyle` / `ToggleStyle` configuration and `@Environment(\.isEnabled)`, so `.disabled(true)` just works.
3. **No hex values or raw numbers in components.** Use role colors (`Color.Button.primary`) and tokens (`.md`, `.radiusMD`, `.fontStyle(.body)`). If a role is missing, add it to the protocol in `DSRoleColors.swift` with a default mapping onto a palette step, then expose it in `Color+DesignSystem.swift`.
4. **Map by scale step, not by hex.** Use the Figma variable's step (`primary-200` → `palette.primary.shade200`); because dark scales are inverted, the same step works in dark mode.
5. **Check `BWTheme`.** Its brand fill inverts, so anything that assumes white-on-brand needs an override there.
6. **Preview in every theme** — RWLabs, BW and Default, light and dark.
7. **Update [`Docs/ComponentInventory.md`](Docs/ComponentInventory.md).**

### Building

Components use UIKit font APIs, so build for iOS (a plain `swift build` targets macOS and won't compile). Open `Package.swift` in Xcode and build the `RWLabsDesignSystem` scheme against an iOS simulator, or from the command line:

```bash
xcodebuild -scheme RWLabsDesignSystem -destination 'generic/platform=iOS Simulator' build
```
