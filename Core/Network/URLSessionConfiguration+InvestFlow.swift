//
//  URLSessionConfiguration+InvestFlow.swift
//  InvestFlow
//
//  Created by Stephano Portella on 08/05/2026.
//

import Foundation

extension URLSessionConfiguration {

    /// Configuración de sesión endurecida para uso fintech.
    ///
    /// Diferencias respecto a `.default`:
    /// - Ephemeral: sin caché en disco, sin cookies persistentes, almacenamiento de
    ///   credenciales aislado.
    /// - `urlCache = nil`: elimina incluso la caché de respuestas en memoria. Los datos
    ///   financieros (balances, posiciones) siempre deben venir del servidor, nunca de una
    ///   copia cacheada.
    /// - `requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData`: señal redundante
    ///   ("cinturón y tirantes") a cualquier capa intermedia de que las respuestas no deben
    ///   servirse desde caché.
    /// - `httpCookieAcceptPolicy = .never` + `httpShouldSetCookies = false`: la API es
    ///   basada en tokens (Bearer). Las cookies son pura superficie de ataque sin ningún
    ///   beneficio.
    /// - `timeoutIntervalForRequest = 30`: fallar rápido ante conexiones estancadas; el
    ///   default de 60 s es demasiado largo para flujos fintech interactivos.
    /// - `timeoutIntervalForResource = 90`: protege ante long-poll descontrolado o servidores
    ///   lentos. El default es de 7 días — prácticamente ilimitado.
    public static var investFlowFintech: URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.urlCache                   = nil
        config.requestCachePolicy         = .reloadIgnoringLocalAndRemoteCacheData
        config.httpCookieAcceptPolicy     = .never
        config.httpShouldSetCookies       = false
        config.timeoutIntervalForRequest  = 30
        config.timeoutIntervalForResource = 90
        return config
    }
}
