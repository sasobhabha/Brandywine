//
//  WhiskyWineInstaller.swift
//  WhiskyKit
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
import SemanticVersion
import os.log

public class WhiskyWineInstaller {
    /// The Whisky application folder
    public static let applicationFolder = FileManager.default.urls(
        for: .applicationSupportDirectory, in: .userDomainMask
        )[0].appending(path: Bundle.whiskyBundleIdentifier)

    /// The folder of all the libfrary files
    public static let libraryFolder = applicationFolder.appending(path: "Libraries")

    /// URL to the installed `wine` `bin` directory
    public static var binFolder: URL {
        let standard = libraryFolder.appending(path: "Wine").appending(path: "bin")
        let fileManager = FileManager.default
        if fileManager.isExecutableFile(atPath: standard.appending(path: "wine").path) ||
            fileManager.isExecutableFile(atPath: standard.appending(path: "wine64").path) {
            return standard
        }
        // Check inside Wine Staging.app bundle (alternative install layout)
        let bundle = libraryFolder
            .appending(path: "Wine Staging.app")
            .appending(path: "Contents")
            .appending(path: "Resources")
            .appending(path: "wine")
            .appending(path: "bin")
        if fileManager.isExecutableFile(atPath: bundle.appending(path: "wine").path) ||
            fileManager.isExecutableFile(atPath: bundle.appending(path: "wine64").path) {
            return bundle
        }
        return standard
    }

    public static func isWhiskyWineInstalled() -> Bool {
        FileManager.default.isExecutableFile(
            atPath: WineBinaryResolver.executableURL(in: binFolder).path
        )
    }

    public static func install(from: URL) throws {
        if GcenxWine.isGcenxArchive(from) {
            if !FileManager.default.fileExists(atPath: libraryFolder.path) {
                try FileManager.default.createDirectory(at: libraryFolder, withIntermediateDirectories: true)
            }
            try GcenxWine.installWine(from: from, libraryFolder: libraryFolder)
        } else {
            if !FileManager.default.fileExists(atPath: libraryFolder.path) {
                try FileManager.default.createDirectory(at: libraryFolder, withIntermediateDirectories: true)
            }
            try Tar.untar(tarBall: from, toURL: libraryFolder)
            try WineBinaryResolver.ensureWine64Symlink(in: binFolder)
        }
        if from.path.contains(FileManager.default.temporaryDirectory.path) {
            try? FileManager.default.removeItem(at: from)
        }
    }

    public static func isBrewInstalled() -> Bool {
        let brewPaths = [
            "/opt/homebrew/bin/brew",
            "/usr/local/bin/brew",
            "/home/linuxbrew/.linuxbrew/bin/brew"
        ]
        for path in brewPaths where FileManager.default.fileExists(atPath: path) {
            return true
        }
        return false
    }

    public static func brewExecutablePath() -> String? {
        let paths = [
            "/opt/homebrew/bin/brew",
            "/usr/local/bin/brew",
            "/home/linuxbrew/.linuxbrew/bin/brew"
        ]
        for path in paths where FileManager.default.fileExists(atPath: path) {
            return path
        }
        return nil
    }

    public static func runBrewInstall() async throws {
        if !isBrewInstalled() {
            try await installHomebrew()
        }
        guard let brew = brewExecutablePath() else {
            throw BrewError.brewNotFound
        }
        try await brewInstallCask(brewPath: brew, cask: "wine@staging")
        try linkWineFromCask()
    }

    /// After `brew install --cask wine@staging`, Wine is placed under
    /// /Applications/Wine Staging.app or /opt/homebrew/Caskroom/wine@staging/<version>.
    /// Symlink wine64 and wineserver into our expected binFolder so the rest of
    /// Brandywine can find them at WhiskyWineInstaller.binFolder.
    private static func linkWineFromCask() throws {
        let caskroomBase = URL(fileURLWithPath: "/opt/homebrew/Caskroom/wine@staging")
        var caskBinDir: URL?

        if FileManager.default.fileExists(atPath: caskroomBase.path) {
            let contents = try FileManager.default.contentsOfDirectory(
                at: caskroomBase, includingPropertiesForKeys: [.isDirectoryKey]
            )
            if let latest = contents.filter({ url -> Bool in
                (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
            }).sorted(by: { $0.lastPathComponent > $1.lastPathComponent }).first {
                let candidate = latest.appendingPathComponent("wine").appendingPathComponent("bin")
                if FileManager.default.fileExists(atPath: candidate.appendingPathComponent("wine").path) {
                    caskBinDir = candidate
                }
            }
        }

        if caskBinDir == nil {
            let appName = "Wine Staging.app"
            let appDir = URL(fileURLWithPath: "/Applications").appendingPathComponent(appName)
            if FileManager.default.fileExists(atPath: appDir.path) {
                let candidate = appDir
                    .appendingPathComponent("Contents")
                    .appendingPathComponent("Resources")
                    .appendingPathComponent("wine")
                    .appendingPathComponent("bin")
                if FileManager.default.fileExists(atPath: candidate.appendingPathComponent("wine").path) {
                    caskBinDir = candidate
                }
            }
        }

        guard let sourceBinDir = caskBinDir else {
            throw BrewError.wine64NotFound
        }

        try FileManager.default.createDirectory(at: binFolder, withIntermediateDirectories: true)

        let wineSrc = sourceBinDir.appendingPathComponent("wine")
        let wineDst = binFolder.appendingPathComponent("wine")
        let wineserverSrc = sourceBinDir.appendingPathComponent("wineserver")
        let wineserverDst = binFolder.appendingPathComponent("wineserver")

        try? FileManager.default.removeItem(at: wineDst)
        try? FileManager.default.removeItem(at: wineserverDst)
        try FileManager.default.createSymbolicLink(at: wineDst, withDestinationURL: wineSrc)
        try FileManager.default.createSymbolicLink(at: wineserverDst, withDestinationURL: wineserverSrc)
        try WineBinaryResolver.ensureWine64Symlink(in: binFolder)
    }

    private static func installHomebrew() async throws {
        let installScript =
            "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
        guard let url = URL(string: installScript) else {
            throw BrewError.invalidURL
        }

        let session = URLSession(configuration: .ephemeral)
        let scriptData: Data = try await withCheckedThrowingContinuation { continuation in
            let task = session.dataTask(with: url) { data, _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let data = data else {
                    continuation.resume(throwing: BrewError.downloadFailed)
                    return
                }
                continuation.resume(returning: data)
            }
            task.resume()
        }

        let tempDir = FileManager.default.temporaryDirectory
        let scriptURL = tempDir.appending(path: "homebrew_install.sh")
        try scriptData.write(to: scriptURL)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [scriptURL.path]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        try? FileManager.default.removeItem(at: scriptURL)

        guard process.terminationStatus == 0 else {
            throw BrewError.homebrewInstallFailed
        }
    }

    private static func brewInstallCask(brewPath: String, cask: String) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: brewPath)
        process.arguments = ["install", "--cask", cask]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw BrewError.caskInstallFailed
        }
    }

    public static func uninstall() {
        do {
            try FileManager.default.removeItem(at: libraryFolder)
        } catch {
            print("Failed to uninstall WhiskyWine: \(error)")
        }
    }

    public static func shouldUpdateWhiskyWine() async -> (Bool, SemanticVersion) {
        let targetVersion = GcenxWine.bundledVersion
        let localVersion = whiskyWineVersion()

        if let localVersion = localVersion {
            if localVersion < targetVersion {
                return (true, targetVersion)
            }
        }

        return (false, SemanticVersion(0, 0, 0))
    }

    public static func whiskyWineVersion() -> SemanticVersion? {
        do {
            let versionPlist = libraryFolder
                .appending(path: "WhiskyWineVersion")
                .appendingPathExtension("plist")

            let decoder = PropertyListDecoder()
            let data = try Data(contentsOf: versionPlist)
            let info = try decoder.decode(WhiskyWineVersion.self, from: data)
            return info.version
        } catch {
            print(error)
            return nil
        }
    }
}

enum BrewError: Error, LocalizedError {
    case brewNotFound
    case invalidURL
    case downloadFailed
    case homebrewInstallFailed
    case caskInstallFailed
    case wine64NotFound

    var errorDescription: String? {
        switch self {
        case .brewNotFound:
            return "Homebrew was not found on this system."
        case .invalidURL:
            return "Invalid Homebrew install script URL."
        case .downloadFailed:
            return "Failed to download the Homebrew install script."
        case .homebrewInstallFailed:
            return "Homebrew installation failed."
        case .caskInstallFailed:
            return "Failed to install wine@staging via Homebrew."
        case .wine64NotFound:
            return "wine64 was not found after installation. Please check that wine@staging is installed via Homebrew."
        }
    }
}

struct WhiskyWineVersion: Codable {
    var version: SemanticVersion = SemanticVersion(11, 0, 0)
}
