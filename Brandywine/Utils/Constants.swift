//
//  Constants.swift
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

import Foundation

enum ViewWidth {
    static let small: Double = 400
    static let medium: Double = 500
    static let large: Double = 600
}

/// Shared loading state used by bottle configuration views.
public enum LoadingState {
    case loading
    case modifying
    case success
    case failed
}

import SwiftUI

/// Minimal shared SettingItemView used as a fallback when the dedicated file isn't compiled into the target.
public struct SettingItemView<Content: View>: View {
    public let title: String.LocalizationValue
    public let loadingState: LoadingState
    @ViewBuilder public var content: () -> Content

    @Namespace private var viewId
    @Namespace private var progressViewId

    public init(
        title: String.LocalizationValue,
        loadingState: LoadingState,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.loadingState = loadingState
        self.content = content
    }

    public var body: some View {
        HStack {
            Text(String(localized: title))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                switch loadingState {
                case .loading, .modifying:
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                        .matchedGeometryEffect(id: progressViewId, in: viewId)
                case .success:
                    content()
                        .labelsHidden()
                        .disabled(loadingState != .success)
                case .failed:
                    Text("config.notAvailable")
                        .font(.caption).foregroundStyle(.red)
                        .multilineTextAlignment(.trailing)
                }
            }
            .animation(.default, value: loadingState)
        }
    }
}
