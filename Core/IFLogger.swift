//
//  IFLogger.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import OSLog

public enum IFLogger {

    // MARK: - Loggers

    nonisolated static let general  = Logger(subsystem: "com.investflow.app", category: "general")
    nonisolated static let network  = Logger(subsystem: "com.investflow.app", category: "network")
    nonisolated static let auth     = Logger(subsystem: "com.investflow.app", category: "auth")
    nonisolated static let domain   = Logger(subsystem: "com.investflow.app", category: "domain")
    nonisolated static let analytics = Logger(subsystem: "com.investflow.app", category: "analytics")

    // MARK: - API pública

    public nonisolated static func debug(
        _ message: String,
        file: String = #file,
        line: Int = #line
    ) {
        let filename = (file as NSString).lastPathComponent
        general.debug("\(filename, privacy: .public):\(line, privacy: .public) — \(message, privacy: .public)")
    }

    public nonisolated static func error(
        _ error: Error,
        context: String = "",
        file: String = #file,
        line: Int = #line
    ) {
        let filename = (file as NSString).lastPathComponent
        let ctx = context.isEmpty ? "" : "[\(context)] "
        general.error("\(ctx, privacy: .public)\(filename, privacy: .public):\(line, privacy: .public) — \(String(describing: error), privacy: .public)")
        // Punto de extensión: reenviar aquí a un SDK de crash-reporting (p. ej. Crashlytics)
        // cuando se agregue uno al proyecto. Deliberadamente sin conectar — todavía no hay
        // ninguna dependencia de terceros.
    }

    public nonisolated static func event(
        _ name: String,
        properties: [String: String] = [:]
    ) {
        let props = properties.isEmpty ? "" : " \(properties)"
        analytics.info("\(name, privacy: .public)\(props, privacy: .public)")
        // Punto de extensión: reenviar aquí a un SDK de analítica de producto (p. ej. Amplitude)
        // cuando se agregue uno al proyecto. Deliberadamente sin conectar — todavía no hay
        // ninguna dependencia de terceros.
    }
}
