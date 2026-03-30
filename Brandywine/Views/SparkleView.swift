//
//  SparkleView.swift
//  Whisky
//
//  This file is part of Whisky.
//
//  Whisky is free software: you can redistribute it and/or modify it under the terms
//  of the GNU General Public License as published by the Free Software Foundation,
//  either version 3 of the License, or (at your option) any later version.
//
//  Whisky is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
//  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//  See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with Whisky.
//  If not, see https://www.gnu.org/licenses/.
//

import SwiftUI
import Sparkle

struct SparkleView: View {
    @ObservedObject private var checkForUpdatesViewModel: CheckForUpdatesViewModel
    private let updater: SPUUpdater

    init(updater: SPUUpdater) {
        self.updater = updater
        self.checkForUpdatesViewModel = CheckForUpdatesViewModel(updater: updater)
    }

    var body: some View {
        Button("check.updates", action: updater.checkForUpdates)
            .disabled(!checkForUpdatesViewModel.canCheckForUpdates)
    }
}

// This view model class publishes when new updates can be checked by the user
final class CheckForUpdatesViewModel: ObservableObject, @unchecked Sendable {
    @Published var canCheckForUpdates = false
    private var updater: SPUUpdater
    private var timer: Timer?

    init(updater: SPUUpdater) {
        self.updater = updater
        // Initial check
        updateCanCheckForUpdates()
        // Poll the updater's state
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCanCheckForUpdates()
        }
    }
    private func updateCanCheckForUpdates() {
        Task { @MainActor [weak self] in
            self?.canCheckForUpdates = self?.updater.canCheckForUpdates ?? false
        }
    }
    deinit {
        timer?.invalidate()
    }
}
