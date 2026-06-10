import SwiftUI
import TokenBarCore

/// The classic TokenBar dashboard stack. The all-agent overview leads with
/// the usage chart; a single-client tab shows that client's slice (the
/// limits-led single-client layout lands with the agent-limits card in a
/// later phase). Agent limits and the live-session trace cards join the
/// stack then too.
struct OverviewView: View {
    let payload: UsagePayload
    /// The active tab's client slice (all present clients on Overview).
    let clientIds: [String]
    let stats: UsageStats
    let modelReport: ModelReport?
    let colors: ModelColorMap
    /// Set when this view shows a single client's slice.
    var singleClient: String?

    var body: some View {
        VStack(spacing: 12) {
            UsageChartCard(
                payload: payload, clientIds: clientIds, stats: stats, colors: colors)
            ModelBreakdownCard(
                report: modelReport, clientIds: clientIds, colors: colors,
                title: singleClient.map { "\(ClientRegistry.style($0).displayName) models" }
                    ?? "Models")
            StreaksCard(streaks: stats.streaks)
        }
    }
}
