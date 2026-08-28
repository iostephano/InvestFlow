//
//  AppCoordinatorTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import SwiftUI
import FinCore
@testable import InvestFlow

@Suite("AppCoordinator")
@MainActor
struct AppCoordinatorTests {

    @Test func initialState_selectedTabIsHome() {
        let coord = AppCoordinator()
        #expect(coord.selectedTab == .home)
    }

    @Test func initialState_noActiveTransfer() {
        let coord = AppCoordinator()
        #expect(coord.activeTransfer == nil)
    }

    @Test func startDeposit_setsActiveTransfer_andClosesDrawer() {
        let coord = AppCoordinator()
        coord.openDrawer()
        coord.startDeposit()
        #expect(coord.activeTransfer == .deposit)
        #expect(!coord.isDrawerOpen)
    }

    @Test func startWithdrawal_setsActiveTransfer() {
        let coord = AppCoordinator()
        coord.startWithdrawal()
        #expect(coord.activeTransfer == .withdrawal)
    }

    @Test func dismissTransfer_clearsActiveTransfer() {
        let coord = AppCoordinator()
        coord.startDeposit()
        coord.dismissTransfer()
        #expect(coord.activeTransfer == nil)
    }

    @Test func performLogout_resetsAllState() {
        let coord = AppCoordinator()
        coord.startDeposit()
        coord.openDrawer()
        coord.isProfilePresented = true
        coord.selectedTab = .market

        coord.performLogout()

        #expect(coord.activeTransfer == nil)
        #expect(!coord.isDrawerOpen)
        #expect(!coord.isProfilePresented)
        #expect(coord.selectedTab == .home)
    }

    @Test func showProfile_setsPresentedAndClosesDrawer() {
        let coord = AppCoordinator()
        coord.openDrawer()
        coord.showProfile()
        #expect(coord.isProfilePresented)
        #expect(!coord.isDrawerOpen)
    }

    @Test func openDrawer_thenClose_togglesCorrectly() {
        let coord = AppCoordinator()
        coord.openDrawer()
        #expect(coord.isDrawerOpen)
        coord.closeDrawer()
        #expect(!coord.isDrawerOpen)
    }

    @Test func navigateToMarket_changesTab() {
        let coord = AppCoordinator()
        coord.navigateToMarket()
        #expect(coord.selectedTab == .market)
        #expect(!coord.isDrawerOpen)
    }

    @Test func navigateToPortfolio_changesTab() {
        let coord = AppCoordinator()
        coord.navigateToPortfolio()
        #expect(coord.selectedTab == .portfolio)
    }
}
