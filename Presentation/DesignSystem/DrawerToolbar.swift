//
//  DrawerToolbar.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI
import FinUI

/// Agrega el botón hamburguesa que abre el drawer a la barra de navegación de un tab raíz.
///
/// HomeView muestra el mismo botón; cada tab raíz (`Inicio`, `Mercado`,
/// `Seguimiento`, `Portafolio`) aplica `.drawerToolbar()` para que el control quede
/// idéntico en icono, posición y comportamiento sin repetir el bloque de toolbar
/// en cada vista.
private struct DrawerToolbarModifier: ViewModifier {

    @Environment(AppCoordinator.self) private var coordinator

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        coordinator.openDrawer()
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.white.opacity(0.88))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Abrir menú")
                }
            }
            .toolbarBackground(Color.ifNavy, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

extension View {
    /// Hamburguesa estándar que abre el drawer para la barra de navegación de un tab raíz.
    func drawerToolbar() -> some View { modifier(DrawerToolbarModifier()) }
}
