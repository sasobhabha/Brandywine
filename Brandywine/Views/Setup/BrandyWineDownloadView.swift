//
//  BrandyWineDownloadView.swift
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

struct WhiskyWineDownloadView: View {
    @State private var isReady: Bool = false
    @State private var statusMessage: String = "Preparing bundled Wine libraries..."
    @State private var secondaryStatusMessage: String?
    @Binding var tarLocation: URL
    @Binding var path: [SetupStage]

    private let macPortsPKGURLString =
        "https://github.com/macports/macports-base/releases/download/v2.12.4/MacPorts-2.12.4-26-Tahoe.pkg"

    var body: some View {
        VStack {
            VStack {
                Text("setup.whiskywine.download")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Downloading Wine 11.6 libraries")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(.circular)
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let secondaryStatusMessage {
                        Text(secondaryStatusMessage)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding()
                Spacer()
            }
            Spacer()
        }
        .frame(width: 400, height: 200)
        .onAppear {
            Task {
                await MainActor.run {
                    statusMessage = "Fetching Wine 11.6 libraries..."
                }
                let downloadURLString =
                    "https://github.com/Gcenx/macOS_Wine_builds/releases/download/11.6/wine-devel-11.6-osx64.tar.xz"
                guard let url = URL(string: downloadURLString) else {
                    await MainActor.run {
                        statusMessage = "Failed to download Wine libraries."
                    }
                    return
                }
                let session = URLSession(configuration: .ephemeral)
                let downloadTask = session.downloadTask(with: url) { downloadURL, _, _ in
                    Task {
                        await MainActor.run {
                            if let downloadURL = downloadURL {
                                tarLocation = downloadURL
                                proceed()
                            } else {
                                statusMessage = "Failed to download Wine libraries."
                            }
                        }
                    }
                }
                downloadTask.resume()
            }
        }
    }

    func proceed() {
        path.append(.whiskyWineInstall)
    }

    private func downloadAndOpenMacPortsPKG() async -> Bool {
        await MainActor.run {
            secondaryStatusMessage = "Fetching MacPorts installer..."
        }
        guard let url = URL(string: macPortsPKGURLString) else {
            await MainActor.run {
                secondaryStatusMessage = "Failed to resolve MacPorts installer URL."
            }
            return false
        }
        let session = URLSession(configuration: .ephemeral)
        return await withCheckedContinuation { continuation in
            let task = session.downloadTask(with: url) { downloadURL, _, _ in
                Task { @MainActor in
                    guard let downloadURL else {
                        secondaryStatusMessage = "Failed to download MacPorts installer."
                        continuation.resume(returning: false)
                        return
                    }
                    secondaryStatusMessage = "Opening MacPorts installer..."
                    #if canImport(AppKit)
                    NSWorkspace.shared.open(downloadURL)
                    #endif
                    continuation.resume(returning: true)
                }
            }
            task.resume()
        }
    }

    private func installD3DMetalViaMacPorts() async -> Bool {
        await MainActor.run {
            secondaryStatusMessage =
                "Installing d3dmetal via MacPorts (administrator privileges required)..."
        }
        // Use AppleScript to prompt for admin privileges and run the command.
        // This avoids needing an interactive TTY for sudo.
        let script =
            "do shell script \"/opt/local/bin/port selfupdate; /opt/local/bin/port install d3dmetal\" " +
            "with administrator privileges"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
            process.waitUntilExit()
            let success = (process.terminationStatus == 0)
            await MainActor.run {
                secondaryStatusMessage = success
                    ? "d3dmetal installed via MacPorts."
                    : "Failed to install d3dmetal via MacPorts."
            }
            return success
        } catch {
            await MainActor.run {
                secondaryStatusMessage = "Failed to execute installer: \(error.localizedDescription)"
            }
            return false
        }
    }

    private func installMacPortsAndD3DMetalPort() async {
        // Download and open MacPorts installer
        let opened = await downloadAndOpenMacPortsPKG()
        guard opened else { return }

        // Give the user time to complete the installer before attempting port install.
        // In a production app, consider detecting installation completion more robustly.
        try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds grace period

        _ = await installD3DMetalViaMacPorts()
    }
}
