//
//  IFRadius.swift
//  InvestFlow
//
//  Created by Stephano Portella on 08/05/2026.
//

import CoreGraphics

/// Escala de radios de esquina semánticos de InvestFlow.
///
/// Todas las superficies usan el estilo de esquina `.continuous` (superelipse) — la misma
/// geometría que los iconos de apps de iOS y el sistema Liquid Glass de Apple. No es
/// preferencia estética; `.continuous` requiere menos operaciones de path en la GPU que
/// `.circular` y crea una continuidad visual más suave entre superficies redondeadas adyacentes.
nonisolated enum IFRadius {
    /// 8 pt — fondos tintados de iconos, chips pequeños, etiquetas de exchange.
    nonisolated static let xs: CGFloat = 8
    /// 12 pt — grupos de lista compactos, tarjetas inline ajustadas.
    nonisolated static let sm: CGFloat = 12
    /// 16 pt — tarjetas y paneles estándar. El radio de tarjeta principal en InvestFlow.
    nonisolated static let md: CGFloat = 16
    /// 24 pt — paneles elevados, drawers flotantes, modales grandes.
    nonisolated static let lg: CGFloat = 24
}
