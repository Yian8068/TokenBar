import Foundation
import Observation
import TokenBarCore

/// The set of analysis lenses, echoing tokscale's TUI tabs. The client tab
/// (Overview/Claude/Codex…, later phase) filters *which* data; this picks
/// *how* it is broken down. The two compose.
enum AppView: String, CaseIterable {
    case overview, models, daily, hourly, stats, agents

    var label: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }
}

/// Shared dashboard data for every lens. Base data (graph + model report)
/// loads when the popover opens; the hourly/agents reports load lazily the
/// first time their lens becomes active, mirroring the Tauri app's
/// empty-year short-circuit hooks.
@MainActor @Observable final class DashboardModel {
    enum Phase {
        case loading
        case ready
        case failed(String)
    }

    private(set) var phase: Phase = .loading
    private(set) var payload: UsagePayload?
    private(set) var stats: UsageStats?
    private(set) var modelReport: ModelReport?
    private(set) var colors = ModelColorMap(report: nil)
    private(set) var hourly: HourlyReport?
    private(set) var agents: AgentsReport?

    /// TBCore is blocking — every fetch hops off the main actor.
    func load() async {
        do {
            async let payloadTask = Task.detached(priority: .userInitiated) {
                try TBCore.graph()
            }.value
            async let reportTask = Task.detached(priority: .userInitiated) {
                try? TBCore.modelReport()
            }.value
            let payload = try await payloadTask
            let report = await reportTask
            self.payload = payload
            stats = UsageStats(payload: payload, selectedClients: Set(payload.summary.clients))
            modelReport = report
            colors = ModelColorMap(report: report)
            phase = .ready
        } catch {
            phase = .failed("Failed to load usage: \(error)")
        }
    }

    /// Fetch the lazy per-lens reports on first activation.
    func ensureData(for view: AppView) async {
        switch view {
        case .hourly where hourly == nil:
            hourly = await Task.detached(priority: .userInitiated) {
                try? TBCore.hourlyReport()
            }.value
        case .agents where agents == nil:
            agents = await Task.detached(priority: .userInitiated) {
                try? TBCore.agentsReport()
            }.value
        default:
            break
        }
    }
}
