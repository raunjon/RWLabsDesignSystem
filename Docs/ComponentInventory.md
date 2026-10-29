# Component Inventory

Figma source: [PlusOne → UI Kit and Components](https://www.figma.com/design/mhtdApKR13mUNcV4DtQGPe/PlusOne?node-id=209-2772&m=dev)
App source: `Sources/RWLabsDesignSystem/DesignSystem/Components/`

"Needs refactor" values (Markdown can't color text, so each one starts with a checkbox):
- ✅ **Done**: matches Figma.
- ⬜ **Yes**: exists in both, not yet aligned with Figma.
- ⬜ **Build**: in Figma only, needs a new component.
- ➖ **No (no design)**: in the app only; it already uses the shared color/type tokens, but there's no Figma design to match.

## In Figma

| Component | In Figma | In app | Needs refactor |
|---|---|---|---|
| CTA Button | Yes: 4 sizes × Primary / Pressed / Secondary / Tertiary / Disabled | `DSButton`, `DSButtonStyle` | ✅ Done |
| Input fields | Yes: Active / Inactive / Autofill / Error × Large / Small | `DSInputField`, `dsInputFieldStyle`, `DSTextField` | ✅ Done |
| Phone number field | Yes | `DSMobileInputField` | ✅ Done |
| OTP field | Yes: 1–5 digits filled, Error | `DSOTPTextField` | ✅ Done |
| Progress indicator | Yes: segmented, steps 1–10 | `DSStepProgress`, `DSProgressBarStyle`, `DSProgressBar` | ✅ Done |
| Loader (circular) | Yes: 25-frame spinner | `DSSpinnerStyle`, `DSProgressCircle` | ✅ Done |
| Loader (dots) | Yes | `DSDotsLoader`, `DSDotsLoaderStyle` | ✅ Done |
| Pill | Yes: Selected / Unselected | `DSPillStyle` (`.large`), `DSChip` | ✅ Done |
| Long Pill | Yes: Selected / Unselected / Info | `DSPillStyle` (`.compact`), `DSInfoPill`, `DSChip` | ✅ Done |
| Field selection (selection cards) | Yes: Selected / Unselected | `DSSelectionCardStyle`, `DSSelectionCard` | ✅ Done |
| Height picker | Yes: cm / ft | `DSWheelPicker`, `DSHeightPicker` | ✅ Done |
| Height toggle | Yes: Ft / Cm | `DSPillToggle`, `DSHeightUnitToggle` | ✅ Done |
| Gender picker | Yes: closed, open dropdown, each option selected | `DSBasePicker`, `DSPicker`, `DSOptionalPicker` | ✅ Done |
| Swipe button | Yes: Inactive / Swipe / Confirm | `DSSliderButton` | ✅ Done |
| Search bar | Yes | `DSSearchBar`, `DSSearchBarWithFilters` | ✅ Done |
| Option dropdown | Yes | `DSOptionDropdown`, `DSMenu` | ✅ Done |
| Popup cards | Yes: 10 types (camera access, oops, upload failed, ID expired…) | `DSPopupCard`, `.dsPopup` (app supplies illustrations and copy) | ✅ Done |
| Badges | Yes: Recommended (animated sheen), ID verified, Photo verified | `DSRecommendedBadge`, `DSLabelBadge` (count/dot `DSBadge` kept) | ✅ Done |
| Tab | Yes: Tab 1 / Tab 2 | `DSSegmentedControl` | ✅ Done |
| Nav Bar (nav icons) | Yes | `.dsTabBarStyle` + `.dsTab` on a native `TabView`; `DSTabBar`, `DSTabBarView` (app supplies icons) | ✅ Done |
| Chat messages | Yes: Sender / Receiver | `DSChatBubble`, `DSChatReactions`, `DSChatAvatar` | ✅ Done |
| Chat typing field | Yes: Empty / Filled / Voice recording / Voice recorded | `DSChatInput`, `DSVoiceWaveform` (app owns recording) | ✅ Done |
| Private chat container | Yes: Online / Offline | `DSChatView`, `DSChatHeader`, `DSChatDatePill` (`DSGroupChatView` uses the same pieces) | ✅ Done |
| Chat fields (chat list rows) | Yes: Direct / Community × Read / Unread | `DSChatListRow`, `DSUnreadBadge` | ✅ Done |
| Cards container | Yes: L / S | `DSCardContainer`, `DSCard` (`.container` look is the default) | ✅ Done |
| Title and subtext | Yes | — | ⬜ Build |
| Photo upload | Yes: Upload / Upload failed / Uploaded / Verified | — | ⬜ Build |
| Verification progress | Yes: stages 1–3 | — | ⬜ Build |
| User goal cards | Yes: 5 types | — | ⬜ Build (on `DSCard`) |
| Card carousel slider | Yes: 5 types | — | ⬜ Build |
| User Info Card | Yes: Small / Large / Find connection / New connection / Mutual connection | — | ⬜ Build |
| Community cards | Yes: X Small / Small / Large / Swipe / Joined | — | ⬜ Build |
| Community Features Tab | Yes: About / Members / Chat / Events / Rules | — | ⬜ Build |
| Tab Bar (top tabs) | Yes | — | ⬜ Build |
| Event card | Yes: Primary / All events / Past / Open / Moderated… | — | ⬜ Build |
| Moderator Card | Yes | — | ⬜ Build |
| Connection buttons | Yes: Connect / Request sent / Send like / Liked | — | ⬜ Build (on `DSButtonStyle`) |
| Connect button | Yes: Connect / Request sent | — | ⬜ Build (on `DSButtonStyle`) |
| Scroll up button | Yes | — | ⬜ Build (on `DSButtonStyle`) |
| Back button | Yes | — | ⬜ Build |
| Page headers | Yes: Single / Decision / Double | — | ⬜ Build |

## In the app only

| Component | In Figma | In app | Needs refactor |
|---|---|---|---|
| Action sheet / bottom sheet | No (styled like the popup cards) | `.dsBottomSheet`, `DSBottomSheet`, `DSActionSheet` | ➖ No (no design) |
| Avatar | No (appears inside user/community cards) | `DSAvatar`, `DSAvatarGroup` | ➖ No (no design) |
| Banner | No | `DSBanner` | ➖ No (no design) |
| Checkbox | No | `DSCheckbox`, `DSCheckboxGroup` | ➖ No (no design) |
| Radio | No | `DSRadio`, `DSRadioGroup` | ➖ No (no design) |
| Color scheme picker | No | `DSColorSchemePicker` | ➖ No (no design) |
| Custom input modal | No | `DSCustomInputModalView` | ➖ No (no design) |
| Input modal | No | `DSInputModalView` | ➖ No (no design) |
| Modal picker | No | `DSModalPicker` (restyled with the picker field and option rows) | ➖ No (no design) |
| Date of birth field | No | `DSDateOfBirthTextField` | ➖ No (no design) |
| Date picker | No | `DSDatePicker` (uses the picker field; calendar opens inline) | ➖ No (no design) |
| Divider | No | `DSDivider` | ➖ No (no design) |
| Empty state | No | `DSEmptyState` | ➖ No (no design) |
| List row | No (closest: Chat fields) | `DSListRow`, `DSListSection` | ➖ No (no design) |
| Range slider | No | `DSRangeSlider` | ➖ No (no design) |
| Slider | No | `DSSlider` | ➖ No (no design) |
| Skeleton | No | `DSSkeleton` | ➖ No (no design) |
| Stepper | No | `DSStepper` | ➖ No (no design) |
| Text | No (uses Figma type styles) | `DSText` | ➖ No (no design) |
| Toast | No | `DSToast` (aligned to the shared card, type and color tokens) | ➖ No (no design) |
| Toggle | No | `DSToggle`, `DSToggleGroup` | ➖ No (no design) |
| Tooltip | No | `DSTooltip` | ➖ No (no design) |

Not listed: Figma's "Component 1" (node 3535:21306) has no descriptive name, and the older "CTA Button" set (189:6113) is superseded by 3270:19445.
