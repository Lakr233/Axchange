//
//  DeviceTestHelpers.swift
//  AxchangeTests
//
//  Created by qaq on 15/12/2025.
//

import AuxiliaryExecute
import Foundation
import Testing

@testable @preconcurrency import Axchange

// MARK: - Device Test Helpers

enum DeviceTestHelpers {
    static var adbPath: String {
        Bundle.main.url(forAuxiliaryExecutable: "adb")?.path ?? "/usr/local/bin/adb"
    }

    static func runADB(_ args: [String], timeout: Double = 10) -> AuxiliaryExecute.ExecuteReceipt {
        AuxiliaryExecute.spawn(command: adbPath, args: args, environment: [:], timeout: timeout)
    }

    static func discoverDevices() -> [(identifier: String, status: Device.Status)] {
        let receipt = runADB(["devices"])
        guard receipt.exitCode == 0, receipt.stdout.hasPrefix("List of devices attached\n") else { return [] }
        return receipt.stdout
            .dropFirst("List of devices attached\n".count)
            .components(separatedBy: "\n")
            .compactMap { line -> (String, Device.Status)? in
                let parts = line.trimmingCharacters(in: .whitespaces).components(separatedBy: "\t")
                guard parts.count == 2, !parts[0].isEmpty else { return nil }
                return (parts[0], parts[1] == "device" ? .authorized : .unauthorized)
            }
    }

    static func getTestDevice() -> Device? {
        discoverDevices().first { $0.status == .authorized }.map { Device(identifier: $0.identifier, status: $0.status) }
    }

    static func requireTestDevice() -> Device? {
        guard let device = getTestDevice() else {
            Issue.record("no authorized device")
            return nil
        }
        return device
    }

    static func assertUploadDownloadOverwriteRenameDelete(
        device: Device,
        fileName: String,
        directory: String = "/sdcard",
    ) async throws {
        let localDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("AxI18N_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: localDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: localDir) }

        let localFile = localDir.appendingPathComponent(fileName)
        let contentV1 = "i18n test v1: \(Date())"
        try contentV1.write(to: localFile, atomically: true, encoding: .utf8)

        let remotePath = RemotePath.join(dir: directory, component: fileName)

        // Create/Upload
        let uploadErr = await withCheckedContinuation { c in
            DispatchQueue.global().async {
                c.resume(returning: device.pushFiles(atPaths: [localFile], toDir: directory) { _, _ in })
            }
        }
        #expect(uploadErr == nil, "upload failed for \(fileName)")

        // Exists (avoid relying on directory listing Unicode behavior)
        let existsAfterUpload = await remotePathExists(device: device, path: remotePath)
        #expect(existsAfterUpload, "file should exist on device: \(fileName)")

        // Update/Overwrite (push same file name, different content)
        let contentV2 = "i18n test v2: \(UUID().uuidString)"
        try contentV2.write(to: localFile, atomically: true, encoding: .utf8)
        let overwriteErr = await withCheckedContinuation { c in
            DispatchQueue.global().async {
                c.resume(returning: device.pushFiles(atPaths: [localFile], toDir: directory) { _, _ in })
            }
        }
        #expect(overwriteErr == nil, "overwrite upload failed for \(fileName)")

        // Download and verify content
        let dlDir = localDir.appendingPathComponent("dl")
        try FileManager.default.createDirectory(at: dlDir, withIntermediateDirectories: true)
        let dlErr = await withCheckedContinuation { c in
            DispatchQueue.global().async {
                c.resume(returning: device.downloadFiles(atPaths: [remotePath], toDest: dlDir) { _, _ in })
            }
        }
        #expect(dlErr == nil, "download failed for \(fileName)")
        let dlFiles = try FileManager.default.contentsOfDirectory(at: dlDir, includingPropertiesForKeys: nil)
        let downloadedUrl = dlFiles.first { $0.lastPathComponent.precomposedStringWithCanonicalMapping == fileName.precomposedStringWithCanonicalMapping }
        #expect(downloadedUrl != nil, "downloaded file not found: \(fileName)")
        if let downloadedUrl {
            let downloaded = try String(contentsOf: downloadedUrl, encoding: .utf8)
            #expect(downloaded == contentV2, "downloaded content mismatch for \(fileName)")
        }

        // Update/Rename
        let renamedFileName = "renamed_\(UUID().uuidString.prefix(4))_\(fileName)"
        let renamedRemotePath = RemotePath.join(dir: directory, component: renamedFileName)
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            DispatchQueue.global().async { device.moveFile(atPath: remotePath, toPath: renamedRemotePath); c.resume() }
        }
        let existsAfterRenameOld = await remotePathExists(device: device, path: remotePath)
        let existsAfterRenameNew = await remotePathExists(device: device, path: renamedRemotePath)
        #expect(!existsAfterRenameOld, "original name should be gone: \(fileName)")
        #expect(existsAfterRenameNew, "renamed file should exist: \(renamedFileName)")

        // Delete
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            DispatchQueue.global().async { device.deleteFiles(atPaths: [renamedRemotePath]); c.resume() }
        }
        let existsAfterDelete = await remotePathExists(device: device, path: renamedRemotePath)
        #expect(!existsAfterDelete, "file should be deleted: \(renamedFileName)")
    }

    private static func remotePathExists(device: Device, path: String) async -> Bool {
        await withCheckedContinuation { c in
            DispatchQueue.global().async {
                for candidate in RemotePath.candidates(for: path) {
                    let receipt = device.executeADB(withParameters: ["shell", "ls", "\"\(candidate)\""], timeout: 3)
                    if receipt.exitCode == 0 {
                        c.resume(returning: true)
                        return
                    }
                }
                c.resume(returning: false)
            }
        }
    }
}
