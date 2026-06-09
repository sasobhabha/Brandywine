//
//  GcenxWineInstallView.swift
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

struct GcenxWineInstallView: View {
    @State var installing: Bool = true
    @State var installFailed: Bool = false
    @State var errorMessage: String = ""
    @Binding var tarLocation: URL
    @Binding var path: [SetupStage]
    @Binding var showSetup: Bool

    var body: some View {
        VStack {
            VStack {
                Text("setup.whiskywine.install")
                    .font(BrandyTheme.titleFont)
                    .foregroundStyle(BrandyTheme.accent)
                Text("setup.whiskywine.install.subtitle")
                    .font(.subheadline)
                    .foregroundStyle(BrandyTheme.accentMuted)
                Spacer()
                if installing {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(width: 80)
                } else if installFailed {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .foregroundStyle(.red)
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .padding(.top, 8)
                } else {
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .foregroundStyle(BrandyTheme.accentMuted)
                }
                Spacer()
            }
            Spacer()
        }
        .frame(width: 400, height: 200)
        .onAppear {
            let location = tarLocation
            Task.detached {
                do {
                    try WhiskyWineInstaller.install(from: location)
                    await MainActor.run {
                        installing = false
                    }
                    sleep(2)
                    await proceed()
                } catch {
                    await MainActor.run {
                        installing = false
                        installFailed = true
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    @MainActor
    func proceed() {
        showSetup = false
    }
}
