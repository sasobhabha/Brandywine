//
//  GcenxWine.swift
//  WhiskyKit
//

import Foundation
import SemanticVersion

public enum GcenxWine {
    public static let staging119URL =
        "https://github.com/Gcenx/macOS_Wine_builds/releases/download/11.9/wine-staging-11.9-osx64.tar.xz"

    public static let bundledVersion = SemanticVersion(11, 9, 0)

    public static func isGcenxArchive(_ url: URL) -> Bool {
        let name = url.lastPathComponent.lowercased()
        return name.hasSuffix(".tar.xz") || name.contains("osx64.tar")
    }

    /// Installs or upgrades the Wine tree from a Gcenx `.tar.xz` without removing DXVK or winetricks.
    public static func installWine(from archive: URL, libraryFolder: URL) throws {
        let fileManager = FileManager.default
        let tempRoot = fileManager.temporaryDirectory
            .appending(path: "whisky-gcenx-\(UUID().uuidString)")

        try fileManager.createDirectory(at: tempRoot, withIntermediateDirectories: true)

        defer {
            try? fileManager.removeItem(at: tempRoot)
        }

        try Tar.untarXz(tarBall: archive, toURL: tempRoot)

        guard let wineRoot = findWineResourcesRoot(in: tempRoot) else {
            throw GcenxWineError.missingWineBundle
        }

        if !fileManager.fileExists(atPath: libraryFolder.path) {
            try fileManager.createDirectory(at: libraryFolder, withIntermediateDirectories: true)
        }

        let destinationWine = libraryFolder.appending(path: "Wine")
        if fileManager.fileExists(atPath: destinationWine.path) {
            try fileManager.removeItem(at: destinationWine)
        }

        try fileManager.copyItem(at: wineRoot, to: destinationWine)

        try WineBinaryResolver.ensureWine64Symlink(
            in: destinationWine.appending(path: "bin")
        )

        try writeVersionPlist(in: libraryFolder, version: bundledVersion)
    }

    private static func findWineResourcesRoot(in extractedRoot: URL) -> URL? {
        let fileManager = FileManager.default

        if let enumerator = fileManager.enumerator(
            at: extractedRoot,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) {
            for case let url as URL in enumerator {
                if url.lastPathComponent == "wine",
                   url.deletingLastPathComponent().lastPathComponent == "Resources",
                   url.deletingLastPathComponent().deletingLastPathComponent().lastPathComponent == "Contents" {
                    return url
                }
            }
        }

        let direct = extractedRoot.appending(path: "Wine")
        if fileManager.fileExists(atPath: direct.path) {
            return direct
        }

        return nil
    }

    private static func writeVersionPlist(in libraryFolder: URL, version: SemanticVersion) throws {
        let plistURL = libraryFolder
            .appending(path: "WhiskyWineVersion")
            .appendingPathExtension("plist")

        let info = WhiskyWineVersion(version: version)
        let data = try PropertyListEncoder().encode(info)
        try data.write(to: plistURL, options: .atomic)
    }
}

public enum GcenxWineError: Error, LocalizedError {
    case missingWineBundle

    public var errorDescription: String? {
        switch self {
        case .missingWineBundle:
            return "Could not find Wine resources inside the Gcenx archive."
        }
    }
}
