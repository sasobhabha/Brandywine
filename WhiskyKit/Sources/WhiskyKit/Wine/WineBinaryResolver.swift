//
//  WineBinaryResolver.swift
//  WhiskyKit
//

import Foundation

public enum WineBinaryResolver {
    /// Gcenx macOS Wine 11.x ships a `wine` binary; older Whisky bundles used `wine64`.
    public static func executableURL(in binFolder: URL) -> URL {
        let wine64 = binFolder.appending(path: "wine64")
        if FileManager.default.isExecutableFile(atPath: wine64.path) {
            return wine64
        }

        let wine = binFolder.appending(path: "wine")
        if FileManager.default.isExecutableFile(atPath: wine.path) {
            return wine
        }

        return wine64
    }

    public static func commandName(in binFolder: URL) -> String {
        executableURL(in: binFolder).lastPathComponent
    }

    /// Whisky tooling expects `wine64` on PATH; Gcenx only provides `wine`.
    public static func ensureWine64Symlink(in binFolder: URL) throws {
        let wine = binFolder.appending(path: "wine")
        let wine64 = binFolder.appending(path: "wine64")

        guard FileManager.default.isExecutableFile(atPath: wine.path) else {
            return
        }

        if FileManager.default.fileExists(atPath: wine64.path) {
            try? FileManager.default.removeItem(at: wine64)
        }

        try FileManager.default.createSymbolicLink(
            atPath: wine64.path,
            withDestinationPath: "wine"
        )
    }
}
