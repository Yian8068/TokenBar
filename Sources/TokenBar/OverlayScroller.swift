import AppKit
import SwiftUI

/// Forces the enclosing NSScrollView onto overlay-style scrollers: invisible
/// at rest, a translucent pill while scrolling, and a brief flash when the
/// popover opens so users learn the content scrolls. The system-wide "always
/// show scroll bars" preference would otherwise pin the legacy track — the
/// ugliest strip in the popover — and fully hiding indicators loses the
/// scroll affordance entirely.
struct OverlayScrollerEnforcer: NSViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { context.coordinator.apply(from: view) }
        // The system flips styles back when the global preference changes;
        // re-assert whenever that happens.
        NotificationCenter.default.addObserver(
            forName: NSScroller.preferredScrollerStyleDidChangeNotification,
            object: nil, queue: .main
        ) { [weak view, coordinator = context.coordinator] _ in
            MainActor.assumeIsolated {
                if let view { coordinator.apply(from: view) }
            }
        }
        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        DispatchQueue.main.async { context.coordinator.apply(from: view) }
    }

    @MainActor
    final class Coordinator {
        private var flashedWindow: ObjectIdentifier?

        func apply(from view: NSView) {
            var candidate: NSView? = view
            while let current = candidate, !(current is NSScrollView) {
                candidate = current.superview
            }
            guard let scroll = candidate as? NSScrollView else { return }
            scroll.scrollerStyle = .overlay
            scroll.autohidesScrollers = true
            // Flash exactly once per window appearance — updateNSView fires
            // on every SwiftUI pass (the 10s rate poll alone re-runs it), and
            // re-flashing kept summoning the scroller back from its fade.
            guard let window = scroll.window else { return }
            let identity = ObjectIdentifier(window)
            if flashedWindow != identity {
                flashedWindow = identity
                scroll.flashScrollers()
            }
        }
    }
}
