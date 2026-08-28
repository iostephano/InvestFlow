//
//  KYCValidationBottomSheet.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import SwiftUI
import FinUI
import FinCore

/// Bottom sheet que informa al usuario sobre su estado KYC y la acción requerida.
struct KYCValidationBottomSheet: View {

    let status: KYCStatus
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            statusIcon
            statusText
            actionButton
        }
        .padding(.horizontal, 28)
        .padding(.top, 20)
        .padding(.bottom, 36)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Icono

    private var statusIcon: some View {
        ZStack {
            Circle()
                .fill(iconColor.opacity(0.12))
                .frame(width: 88, height: 88)
            Image(systemName: iconName)
                .font(.system(size: 40))
                .foregroundStyle(iconColor)
        }
    }

    // MARK: - Texto

    private var statusText: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.ifTitle)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.ifBody)
                .foregroundStyle(.ifSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Acción

    private var actionButton: some View {
        Button(actionTitle, action: onDismiss)
            .buttonStyle(.borderedProminent)
            .tint(.ifBlue)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Contenido según estado

    private var title: String {
        switch status {
        case .pending:  return "Verificación requerida"
        case .inReview: return "Verificación en proceso"
        case .approved: return "Identidad verificada"
        case .rejected: return "Verificación rechazada"
        }
    }

    private var subtitle: String {
        switch status {
        case .pending:
            return "Para transferir fondos necesitas completar tu verificación de identidad. Solo tarda unos minutos."
        case .inReview:
            return "Tu solicitud está siendo revisada. Te notificaremos cuando esté lista, generalmente en 24-48 horas."
        case .approved:
            return "Tu identidad está verificada y puedes operar con total seguridad."
        case .rejected:
            return "Tu verificación fue rechazada. Contacta a nuestro equipo de soporte para resolver el problema."
        }
    }

    private var actionTitle: String {
        switch status {
        case .pending:  return "Verificar identidad"
        case .inReview: return "Entendido"
        case .approved: return "Continuar"
        case .rejected: return "Contactar soporte"
        }
    }

    private var iconName: String {
        switch status {
        case .pending:  return "person.badge.key.fill"
        case .inReview: return "clock.badge.checkmark.fill"
        case .approved: return "checkmark.shield.fill"
        case .rejected: return "exclamationmark.shield.fill"
        }
    }

    private var iconColor: Color {
        switch status {
        case .pending:  return .ifBlue
        case .inReview: return Color.orange
        case .approved: return .ifGreen
        case .rejected: return .ifRed
        }
    }
}
