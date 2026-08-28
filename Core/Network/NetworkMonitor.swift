//
//  NetworkMonitor.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import Network
import FinCore

/// Proactive network reachability monitor.
/// Subscribe via `isConnected` or observe path updates.
actor NetworkMonitor {

    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.investflow.network-monitor", qos: .utility)

    private(set) var isConnected: Bool = true

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { [weak self] in
                await self?.updatePath(path)
            }
        }
        monitor.start(queue: monitorQueue)
    }

    private func updatePath(_ path: NWPath) {
        isConnected = path.status == .satisfied
        if !isConnected {
            IFLogger.debug("Network connectivity lost")
        }
    }

    /// Throws `IFError.networkUnavailable` when offline.
    func assertConnected() throws {
        guard isConnected else {
            throw IFError.networkUnavailable
        }
    }
}
