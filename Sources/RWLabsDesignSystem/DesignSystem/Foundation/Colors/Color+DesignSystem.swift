//
//  Color+DesignSystem.swift
//  RWLDesignSystem
//
//  Theme-aware color accessors used by components. Every value resolves through the
//  current theme's `DSColorPalette`.
//

import SwiftUI

@MainActor
public extension Color {

    /// The active palette, for direct access to a scale step, e.g. `Color.palette.primary.shade300`.
    static var palette: any DSColorPalette { DesignSystem.theme.colors }

    // MARK: - Semantic Colors
    @MainActor
    struct Semantic {
        public static var error:   Color { palette.error.base   }
        public static var success: Color { palette.success.base }
        public static var warning: Color { palette.warning.base }
        public static var info:    Color { palette.info.base    }
    }

    @MainActor
    struct Text {
        public static var brand:       Color { palette.text.brand       }
        public static var primary:     Color { palette.text.primary     }
        public static var secondary:   Color { palette.text.secondary   }
        public static var tertiary:    Color { palette.text.tertiary    }
        public static var disabled:    Color { palette.text.disabled    }
        public static var inverse:     Color { palette.text.inverse     }
        public static var placeholder: Color { palette.text.placeholder }
        public static var error:       Color { palette.text.error       }
        public static var white:       Color { palette.white            }
        public static var black:       Color { palette.black            }
    }

    @MainActor
    struct Background {
        public static var primary:          Color { palette.background.primary          }
        public static var secondary:        Color { palette.background.secondary        }
        public static var tertiary:         Color { palette.background.tertiary         }
        public static var secondaryInverse: Color { palette.background.secondaryInverse }
        public static var tertiaryInverse:  Color { palette.background.tertiaryInverse  }
        public static var inverse:          Color { palette.background.inverse          }
        public static var brand:            Color { palette.background.brand            }
        public static var brandInverse:     Color { palette.background.brandInverse     }
    }

    @MainActor
    struct Border {
        public static var focused:     Color { palette.border.focused     }
        public static var subtle:      Color { palette.border.subtle      }
        public static var inverse:     Color { palette.border.inverse     }
        public static var disabled:    Color { palette.border.disabled    }
        public static var placeholder: Color { palette.border.placeholder }
        public static var active:      Color { palette.border.active      }
        public static var error:       Color { palette.border.error       }
    }

    @MainActor
    struct Button {
        public static var primary:            Color { palette.button.primary            }
        public static var primaryText:        Color { palette.button.primaryText        }
        public static var primaryPressed:     Color { palette.button.primaryPressed     }
        public static var secondary:          Color { palette.button.secondary          }
        public static var secondaryText:      Color { palette.button.secondaryText      }
        public static var secondaryPressed:   Color { palette.button.secondaryPressed   }
        public static var tertiary:           Color { palette.button.tertiary           }
        public static var tertiaryText:       Color { palette.button.tertiaryText       }
        public static var tertiaryBorder:     Color { palette.button.tertiaryBorder     }
        public static var tertiaryPressed:    Color { palette.button.tertiaryPressed    }
        public static var disabled:           Color { palette.button.disabled           }
        public static var disabledText:       Color { palette.button.disabledText       }
        public static var destructive:        Color { palette.button.destructive        }
        public static var destructiveText:    Color { palette.button.destructiveText    }
        public static var destructivePressed: Color { palette.button.destructivePressed }
        public static var inverse:            Color { palette.button.inverse            }
        public static var inverseText:        Color { palette.button.inverseText        }
        public static var inversePressed:     Color { palette.button.inversePressed     }
        public static var linkText:           Color { palette.button.linkText           }
        public static var brandLinkText:      Color { palette.button.brandLinkText      }
    }

    @MainActor
    struct Icon {
        public static var primary:        Color { palette.icon.primary        }
        public static var secondary:      Color { palette.icon.secondary      }
        public static var inverse:        Color { palette.icon.inverse        }
        public static var brand:          Color { palette.icon.brand          }
        public static var brandSecondary: Color { palette.icon.brandSecondary }
        public static var brandTertiary:  Color { palette.icon.brandTertiary  }
        public static var brandAccent:    Color { palette.icon.brandAccent    }
        public static var placeholder:    Color { palette.icon.placeholder    }
        public static var white:          Color { palette.white               }
        public static var black:          Color { palette.black               }
    }

    @MainActor
    struct Input {
        public static var text:               Color { palette.input.text               }
        public static var placeholder:        Color { palette.input.placeholder        }
        public static var title:              Color { palette.input.title              }
        public static var helper:             Color { palette.input.helper             }
        public static var helperError:        Color { palette.input.helperError        }
        public static var background:         Color { palette.input.background         }
        public static var border:             Color { palette.input.border             }
        public static var borderFocused:      Color { palette.input.borderFocused      }
        public static var borderError:        Color { palette.input.borderError        }
        public static var autofillBackground: Color { palette.input.autofillBackground }
        public static var autofillText:       Color { palette.input.autofillText       }
        public static var otpBorderEmpty:     Color { palette.input.otpBorderEmpty     }
        public static var icon:               Color { palette.input.icon               }
    }

    @MainActor
    struct Progress {
        public static var fill:         Color { palette.progress.fill         }
        public static var track:        Color { palette.progress.track        }
        public static var spinnerTrack: Color { palette.progress.spinnerTrack }
        public static var dots:         Color { palette.progress.dots         }
    }

    @MainActor
    struct Selection {
        public static var indicatorBorder: Color { palette.selection.indicatorBorder }
        public static var indicatorFill:   Color { palette.selection.indicatorFill   }
        public static var indicatorCheck:  Color { palette.selection.indicatorCheck  }
        public static var surface:         Color { palette.selection.surface         }
        public static var surfaceSelected: Color { palette.selection.surfaceSelected }
        public static var border:          Color { palette.selection.border          }
        public static var borderSelected:  Color { palette.selection.borderSelected  }
        public static var shadow:          Color { palette.selection.shadow          }
        public static var iconBackground:  Color { palette.selection.iconBackground  }
        public static var wheelHighlight:  Color { palette.selection.wheelHighlight  }
        public static var toggleTrack:     Color { palette.selection.toggleTrack     }
        public static var toggleThumb:     Color { palette.selection.toggleThumb     }
    }

    @MainActor
    struct Pill {
        public static var text:                Color { palette.pill.text                }
        public static var border:              Color { palette.pill.border              }
        public static var selectedFill:        Color { palette.pill.selectedFill        }
        public static var removeFill:          Color { palette.pill.removeFill          }
        public static var removeIcon:          Color { palette.pill.removeIcon          }
        public static var compactBorder:       Color { palette.pill.compactBorder       }
        public static var compactSelectedFill: Color { palette.pill.compactSelectedFill }
        public static var compactSelectedText: Color { palette.pill.compactSelectedText }
        public static var infoFill:            Color { palette.pill.infoFill            }
        public static var infoBorder:          Color { palette.pill.infoBorder          }
    }

    @MainActor
    struct Badge {
        public static var highlightFill: Color { palette.badge.highlightFill }
        public static var highlightText: Color { palette.badge.highlightText }
        public static var brandFill:     Color { palette.badge.brandFill     }
        public static var brandText:     Color { palette.badge.brandText     }
        public static var brandIcon:     Color { palette.badge.brandIcon     }
        public static var neutralFill:   Color { palette.badge.neutralFill   }
        public static var neutralText:   Color { palette.badge.neutralText   }
    }

    @MainActor
    struct Swipe {
        public static var track:          Color { palette.swipe.track }
        public static var label:          Color { palette.swipe.label }
        public static var knob:           Color { palette.swipe.knob }
        public static var knobIcon:       Color { palette.swipe.knobIcon }
        public static var confirmedTrack: Color { palette.swipe.confirmedTrack }
        public static var confirmedKnob:  Color { palette.swipe.confirmedKnob }
        public static var confirmedIcon:  Color { palette.swipe.confirmedIcon }
    }

    @MainActor
    struct Search {
        public static var field:       Color { palette.search.field }
        public static var text:        Color { palette.search.text }
        public static var placeholder: Color { palette.search.placeholder }
        public static var icon:        Color { palette.search.icon }
        public static var backFill:    Color { palette.search.backFill }
        public static var backIcon:    Color { palette.search.backIcon }
    }

    @MainActor
    struct Popup {
        public static var card:      Color { palette.popup.card }
        public static var scrim:     Color { palette.popup.scrim }
        public static var title:     Color { palette.popup.title }
        public static var message:   Color { palette.popup.message }
        public static var closeFill: Color { palette.popup.closeFill }
        public static var closeIcon: Color { palette.popup.closeIcon }
    }

    @MainActor
    struct Card {
        public static var surface:   Color { palette.card.surface }
        public static var border:    Color { palette.card.border }
        public static var shadow:    Color { palette.card.shadow }
        public static var title:     Color { palette.card.title }
        public static var message:   Color { palette.card.message }
        public static var accessory: Color { palette.card.accessory }
    }

    @MainActor
    struct Tab {
        public static var border:       Color { palette.tab.border }
        public static var selectedFill: Color { palette.tab.selectedFill }
        public static var selectedText: Color { palette.tab.selectedText }
        public static var text:         Color { palette.tab.text }
    }

    @MainActor
    struct NavBar {
        public static var bar:        Color { palette.navBar.bar }
        public static var selected:   Color { palette.navBar.selected }
        public static var unselected: Color { palette.navBar.unselected }
        public static var shadow:     Color { palette.navBar.shadow }
    }

    @MainActor
    struct Chat {
        public static var bar: Color { palette.chat.bar }
        public static var barBorder: Color { palette.chat.barBorder }
        public static var surface: Color { palette.chat.surface }
        public static var title: Color { palette.chat.title }
        public static var icon: Color { palette.chat.icon }
        public static var senderBubble: Color { palette.chat.senderBubble }
        public static var senderText: Color { palette.chat.senderText }
        public static var senderTime: Color { palette.chat.senderTime }
        public static var receiverText: Color { palette.chat.receiverText }
        public static var receiverTime: Color { palette.chat.receiverTime }
        public static var reactionBorder: Color { palette.chat.reactionBorder }
        public static var reactionCount: Color { palette.chat.reactionCount }
        public static var inputText: Color { palette.chat.inputText }
        public static var activeFill: Color { palette.chat.activeFill }
        public static var activeIcon: Color { palette.chat.activeIcon }
        public static var recordingFill: Color { palette.chat.recordingFill }
        public static var recordingAccent: Color { palette.chat.recordingAccent }
        public static var waveform: Color { palette.chat.waveform }
        public static var recordedTime: Color { palette.chat.recordedTime }
        public static var online: Color { palette.chat.online }
        public static var lastSeen: Color { palette.chat.lastSeen }
        public static var previewUnread: Color { palette.chat.previewUnread }
        public static var previewRead: Color { palette.chat.previewRead }
        public static var source: Color { palette.chat.source }
        public static var timeUnread: Color { palette.chat.timeUnread }
        public static var timeRead: Color { palette.chat.timeRead }
        public static var unreadBadge: Color { palette.chat.unreadBadge }
        public static var unreadBadgeText: Color { palette.chat.unreadBadgeText }
        public static var divider: Color { palette.chat.divider }
    }

    @MainActor
    struct Shadow {
        public static var primary: Color { palette.shadow }
    }

    static var brand:   Color { palette.primary.base }
    static var success: Color { Semantic.success }
    static var error:   Color { Semantic.error   }
    static var text:    Color { Text.primary     }
}
