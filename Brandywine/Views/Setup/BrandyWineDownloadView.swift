//
//  WhiskyWineDownloadView.swift
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
    @Binding var tarLocation: URL
    @Binding var path: [SetupStage]
    var body: some View {
        VStack {
            VStack {
                Text("setup.whiskywine.download")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Downloading Wine 11.0 libraries")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(.circular)
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
                    statusMessage = "Fetching Wine 11.0 libraries..."
                }
                let downloadURLString = "https://github.com/frankea/Whisky/releases/download/v3.0.0/Libraries.tar.gz"
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
}
