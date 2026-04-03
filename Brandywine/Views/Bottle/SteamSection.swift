//
//  SteamCompatibilitySection.swift
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

struct SteamSection: View {
    @ObservedObject var bottle: Bottle

    var body: some View {
        guard SteamHelper.isSteamInstalled(bottle: bottle) else { return AnyView(EmptyView()) }

        let (isOptimized, _) = SteamHelper.validateSteamConfiguration(bottle: bottle)

        return AnyView(
            Section("Steam Compatibility Layer") {
                if isOptimized {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Steam Compatibility Optimized", systemImage: "checkmark.circle.fill")
                            .symbolRenderingMode(.multicolor)
                            .foregroundStyle(.green)

                        Text(SteamHelper.getSteamOptimizationStatus(bottle: bottle))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Label(
                            "Steam requires compatibility optimization",
                            systemImage: "exclamationmark.triangle.fill"
                        )
                        .symbolRenderingMode(.multicolor)

                        Text(
                            "Apply the Steam Compatibility Layer to enable:\n" +
                            "• Windows 11 VM environment\n" +
                            "• MSYNC synchronization\n" +
                            "• DXVK graphics acceleration\n" +
                            "• Critical registry optimizations"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        Button {
                            Task {
                                _ = try await SteamHelper.applySteamOptimization(bottle: bottle)
                            }
                        } label: {
                            Text("Enable Steam Compatibility")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    }
                    .padding(.vertical, 4)
                }
            }
        )
    }
}
