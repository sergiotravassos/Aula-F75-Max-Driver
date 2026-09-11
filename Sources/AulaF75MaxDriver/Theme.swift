import AppKit
import SwiftUI

/// Colours that follow the system appearance.
///
/// The UI was written against a dark window: content in `.white` at various
/// opacities, wells in `.black`, a dark gradient behind everything. Rather than
/// thread `@Environment(\.colorScheme)` through every view, these resolve
/// themselves — `NSColor(name:dynamicProvider:)` is asked for its value each
/// time it is drawn, so a single declaration covers both appearances and
/// follows the system when the user switches.
extension Color {
    private static func dynamic(light: NSColor, dark: NSColor) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? dark : light
        })
    }

    /// Content: text, icons, hairlines. Also the tint for subtle fills, which
    /// is why it inverts rather than staying white — a 6% white wash reads as a
    /// raised panel on dark and as nothing at all on light.
    static let ink = dynamic(light: .black, dark: .white)

    /// The opposite of `ink`. For recessed wells, which are darker than their
    /// surroundings in dark mode and lighter in light mode.
    static let well = dynamic(light: .white, dark: .black)

    /// The accent survives both appearances, but pure orange on white is
    /// glaring, so the light variant is taken down a little.
    static let brand = dynamic(
        light: NSColor(srgbRed: 0.85, green: 0.45, blue: 0.05, alpha: 1),
        dark: NSColor(srgbRed: 1.00, green: 0.58, blue: 0.00, alpha: 1)
    )

    static let ok = dynamic(
        light: NSColor(srgbRed: 0.11, green: 0.55, blue: 0.24, alpha: 1),
        dark: NSColor(srgbRed: 0.30, green: 0.85, blue: 0.39, alpha: 1)
    )

    /// The soft glow behind the panels. Barely there on light, where a strong
    /// wash would muddy the pale gradient instead of lifting it.
    static let halo = dynamic(
        light: NSColor(srgbRed: 0.20, green: 0.55, blue: 0.60, alpha: 0.05),
        dark: NSColor(srgbRed: 0.20, green: 0.70, blue: 0.70, alpha: 0.14)
    )

    static let warn = dynamic(
        light: NSColor(srgbRed: 0.78, green: 0.16, blue: 0.16, alpha: 1),
        dark: NSColor(srgbRed: 1.00, green: 0.42, blue: 0.42, alpha: 1)
    )
}

enum Backdrop {
    /// The window background. Dark keeps the original three-stop gradient; light
    /// is a much flatter, paler version of the same hues, because the same
    /// contrast that reads as depth on dark reads as dirt on light.
    static var gradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.dynamicBackdrop(0), Color.dynamicBackdrop(1), Color.dynamicBackdrop(2),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private extension Color {
    static func dynamicBackdrop(_ stop: Int) -> Color {
        let light: [NSColor] = [
            NSColor(srgbRed: 0.97, green: 0.97, blue: 0.98, alpha: 1),
            NSColor(srgbRed: 0.94, green: 0.95, blue: 0.96, alpha: 1),
            NSColor(srgbRed: 0.96, green: 0.94, blue: 0.91, alpha: 1),
        ]
        let dark: [NSColor] = [
            NSColor(srgbRed: 0.03, green: 0.05, blue: 0.06, alpha: 1),
            NSColor(srgbRed: 0.07, green: 0.11, blue: 0.12, alpha: 1),
            NSColor(srgbRed: 0.14, green: 0.10, blue: 0.04, alpha: 1),
        ]
        return Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? dark[stop] : light[stop]
        })
    }
}

/// SwiftUI resolves the leading-dot shorthand in `.foregroundStyle(.ink)` and
/// `.fill(.brand)` through `ShapeStyle`, not through `Color`, so the names have
/// to exist on both. These forward to the definitions above.
extension ShapeStyle where Self == Color {
    static var ink: Color { Color.ink }
    static var well: Color { Color.well }
    static var brand: Color { Color.brand }
    static var ok: Color { Color.ok }
    static var warn: Color { Color.warn }
}
