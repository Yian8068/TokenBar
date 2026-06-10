import SwiftUI
import TokenBarCore

/// Client tab row (Overview + one tab per present client), port of
/// DashboardTabs.tsx: horizontal scroll, active tab kept in view. SVG agent
/// icons arrive in a later phase — tabs show a brand-color disc with the
/// client's initial, the registry fallback the web app uses for icon-less
/// agents.
struct DashboardTabs: View {
    let clients: [String]
    @Binding var active: String

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    tab(id: "overview", label: "Overview", color: nil)
                    ForEach(clients, id: \.self) { id in
                        let style = ClientRegistry.style(id)
                        tab(id: id, label: ClientRegistry.shortName(id), color: style.color)
                    }
                }
            }
            .onChange(of: active) { _, next in
                withAnimation(.easeOut(duration: 0.15)) {
                    proxy.scrollTo(next, anchor: nil)
                }
            }
        }
    }

    private func tab(id: String, label: String, color: String?) -> some View {
        Button {
            active = id
        } label: {
            HStack(spacing: 5) {
                if let color {
                    Text(String(label.prefix(1)).uppercased())
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 14, height: 14)
                        .background(Color(hex: color), in: Circle())
                }
                Text(label)
                    .font(.caption.weight(active == id ? .semibold : .regular))
                    .lineLimit(1)
                    .fixedSize()
            }
            .foregroundStyle(active == id ? .primary : .secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                active == id ? AnyShapeStyle(.quaternary) : AnyShapeStyle(.clear),
                in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .id(id)
    }
}
