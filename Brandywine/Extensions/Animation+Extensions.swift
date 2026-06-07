//
//  Animation+Extensions.swift
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

extension Animation {
    static var whiskyDefault: Animation {
        .easeInOut(duration: 0.2)
    }
}

extension View {
    /// Soft off-white app canvas.
    func brandAppBackground() -> some View {
        background(BrandyTheme.canvas.ignoresSafeArea())
    }

    /// White surface with a hairline border — no glass, no heavy shadow.
    func brandSurface(cornerRadius: CGFloat = 12) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(BrandyTheme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(BrandyTheme.border, lineWidth: 1)
        )
        .shadow(color: BrandyTheme.shadow, radius: 10, y: 3)
    }

    func brandSidebarStyle() -> some View {
        background(BrandyTheme.sidebar)
    }
}

struct BrandPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(BrandyTheme.accent.opacity(configuration.isPressed ? 0.85 : 1))
            )
            .foregroundStyle(.white)
    }
}

struct BrandSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .regular))
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(BrandyTheme.border, lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(BrandyTheme.surface.opacity(configuration.isPressed ? 0.92 : 1))
                    )
            )
            .foregroundStyle(BrandyTheme.accent)
    }
}
