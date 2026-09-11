import AppKit
import SwiftUI

@main
struct AulaF75MaxDriverApp: App {
    @StateObject private var model = AppViewModel()

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
                .environmentObject(model)
                .background(WindowAppearanceConfigurator(
                    refreshToken: model.selectedLanguageCode,
                    theme: model.selectedTheme
                ))
        }
        .windowResizability(.contentSize)
    }
}

private final class WindowAppearanceView: NSView {
    var configureWindow: ((NSWindow?) -> Void)?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        configureWindow?(window)
    }
}

private struct WindowAppearanceConfigurator: NSViewRepresentable {
    let refreshToken: String
    let theme: AppTheme

    func makeNSView(context: Context) -> WindowAppearanceView {
        let view = WindowAppearanceView(frame: .zero)
        let theme = self.theme
        view.configureWindow = { window in
            Self.configureRepeatedly(window: window, theme: theme)
        }
        Self.configureRepeatedly(window: view.window, theme: theme)
        return view
    }

    func updateNSView(_ nsView: WindowAppearanceView, context: Context) {
        _ = refreshToken
        Self.configureRepeatedly(window: nsView.window, theme: theme)
    }

    @MainActor
    private static func configureRepeatedly(window: NSWindow?, theme: AppTheme) {
        configure(window: window, theme: theme)

        DispatchQueue.main.async {
            configure(window: window, theme: theme)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(80)) {
            configure(window: window, theme: theme)
        }
    }

    @MainActor
    private static func configure(window: NSWindow?, theme: AppTheme) {
        guard let window else { return }

        window.styleMask.insert(.fullSizeContentView)
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .visible

        // A nil appearance means "inherit", which is how the system default is
        // spelled. Set it on the app as well so menus and panels agree with the
        // window.
        let appearance = theme.nsAppearance
        window.appearance = appearance
        NSApp?.appearance = appearance

        // This used to be a fixed dark colour. It is mostly hidden behind the
        // content gradient, but it shows through during resize and in the
        // titlebar, where a dark slab under a light window is very visible.
        window.backgroundColor = NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
                ? NSColor(srgbRed: 0.03, green: 0.05, blue: 0.06, alpha: 1)
                : NSColor(srgbRed: 0.97, green: 0.97, blue: 0.98, alpha: 1)
        }
    }
}
