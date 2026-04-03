//
//  GamingPerformanceSection.swift
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

struct GamingPerformanceSection: View {
    @Binding var isExpanded: Bool

    var body: some View {
        Section("Gaming Performance", isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 12) {
                Label("Performance Optimization Tips", systemImage: "bolt.fill")
                    .font(.headline)
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "1.circle.fill")
                            .foregroundStyle(.blue)
                        Text("Use Windows 11 for better compatibility")
                            .font(.caption)
                    }
                    HStack(spacing: 8) {
                        Image(systemName: "2.circle.fill")
                            .foregroundStyle(.blue)
                        Text("Enable MSYNC synchronization for stability")
                            .font(.caption)
                    }
                    HStack(spacing: 8) {
                        Image(systemName: "3.circle.fill")
                            .foregroundStyle(.blue)
                        Text("Enable DXVK for improved graphics")
                            .font(.caption)
                    }
                    HStack(spacing: 8) {
                        Image(systemName: "4.circle.fill")
                            .foregroundStyle(.blue)
                        Text("Use Metal HUD to monitor GPU usage")
                            .font(.caption)
                    }
                }
                .padding(.vertical, 8)
            }
            .padding(.vertical, 4)
        }
    }
}
