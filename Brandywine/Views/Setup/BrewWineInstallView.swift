//
//  BrewWineInstallView.swift
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
import WhiskyKit

struct BrewWineInstallView: View {
    @State private var statusMessage: String = "Checking for Homebrew..."
    @State private var isInstalling: Bool = true
    @State private var installFailed: Bool = false
    @State private var failureMessage: String = ""
    @Binding var path: [SetupStage]
    @Binding var showSetup: Bool

    var body: some View {
        VStack {
            VStack {
                Text("setup.whiskywine.install")
                    .font(.title)
                    .fontWeight(.bold)
                Text("setup.whiskywine.install.subtitle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                if isInstalling {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(width: 80)
                } else if installFailed {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(.red)
                } else {
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(.green)
                }
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(installFailed ? .red : .secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                Spacer()
            }
            Spacer()
            if installFailed {
                HStack {
                    Button("setup.quit") {
                        exit(0)
                    }
                    .keyboardShortcut(.cancelAction)
                    Spacer()
                    Button("setup.retry") {
                        installFailed = false
                        isInstalling = true
                        startInstall()
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
        }
        .frame(width: 400, height: 200)
        .onAppear {
            startInstall()
        }
    }

    private func startInstall() {
        Task {
            await MainActor.run {
                if WhiskyWineInstaller.isBrewInstalled() {
                    statusMessage = "Homebrew found. Installing wine@staging..."
                } else {
                    statusMessage = "Homebrew not found. Installing Homebrew first..."
                }
            }

            do {
                try await WhiskyWineInstaller.runBrewInstall()

                await MainActor.run {
                    isInstalling = false
                    statusMessage = "Wine installed successfully."
                }
                sleep(2)
                await MainActor.run {
                    showSetup = false
                }
            } catch {
                await MainActor.run {
                    isInstalling = false
                    installFailed = true
                    failureMessage = error.localizedDescription
                    statusMessage = failureMessage
                }
            }
        }
    }
}
