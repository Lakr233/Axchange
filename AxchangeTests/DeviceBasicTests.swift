//
//  DeviceBasicTests.swift
//  AxchangeTests
//
//  Created by qaq on 15/12/2025.
//

import AuxiliaryExecute
import Foundation
import Testing

@testable @preconcurrency import Axchange

// MARK: - Device Basic Integration Tests

@Suite(.serialized)
struct DeviceBasicTests {
    @Test func discoverConnectedDevices() async throws {
        let devices = DeviceTestHelpers.discoverDevices()
        print("[+] discovered \(devices.count) device(s)")
        #expect(devices.isEmpty == false, "no device connected")
    }

    @Test func listSdcardDirectory() async throws {
        guard let device = DeviceTestHelpers.getTestDevice() else {
            Issue.record("no authorized device")
            return
        }
        let files = await withCheckedContinuation { cont in
            DispatchQueue.global().async { cont.resume(returning: device.listDir(atPath: "/sdcard")) }
        }
        print("[+] /sdcard contains \(files.count) items")
        #expect(files.isEmpty == false)
    }

    @Test func createAndDeleteFolder() async throws {
        guard let device = DeviceTestHelpers.getTestDevice() else {
            Issue.record("no authorized device")
            return
        }
        let folder = "/sdcard/AxTest_\(UUID().uuidString.prefix(8))"
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            DispatchQueue.global().async { device.createFolder(atPath: folder); c.resume() }
        }
        var files = await withCheckedContinuation { c in
            DispatchQueue.global().async { c.resume(returning: device.listDir(atPath: "/sdcard")) }
        }
        #expect(files.contains { $0.name == (folder as NSString).lastPathComponent }, "folder should exist")

        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            DispatchQueue.global().async { device.deleteFiles(atPaths: [folder]); c.resume() }
        }
        files = await withCheckedContinuation { c in
            DispatchQueue.global().async { c.resume(returning: device.listDir(atPath: "/sdcard")) }
        }
        #expect(!files.contains { $0.name == (folder as NSString).lastPathComponent }, "folder should be deleted")
        print("[+] create/delete folder passed")
    }

    @Test func uploadDownloadAndDelete() async throws {
        guard let device = DeviceTestHelpers.getTestDevice() else {
            Issue.record("no authorized device")
            return
        }
        let content = "test \(Date())"
        let localDir = FileManager.default.temporaryDirectory.appendingPathComponent("AxTest_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: localDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: localDir) }

        let localFile = localDir.appendingPathComponent("test.txt")
        try content.write(to: localFile, atomically: true, encoding: .utf8)

        let remotePath = "/sdcard/test_\(UUID().uuidString.prefix(8)).txt"
        let remoteDir = RemotePath.deletingLastComponent(remotePath)
        let fileName = RemotePath.lastComponent(remotePath)

        // upload
        let err = await withCheckedContinuation { c in
            DispatchQueue.global().async {
                // rename local file to match remote name
                let renamedLocal = localDir.appendingPathComponent(fileName)
                try? FileManager.default.moveItem(at: localFile, to: renamedLocal)
                c.resume(returning: device.pushFiles(atPaths: [renamedLocal], toDir: remoteDir) { _, _ in })
            }
        }
        #expect(err == nil, "upload failed")

        // verify
        var files = await withCheckedContinuation { c in
            DispatchQueue.global().async { c.resume(returning: device.listDir(atPath: remoteDir)) }
        }
        #expect(files.contains { $0.name == fileName }, "file should exist on device")

        // download
        let dlDir = localDir.appendingPathComponent("dl")
        try FileManager.default.createDirectory(at: dlDir, withIntermediateDirectories: true)
        let dlErr = await withCheckedContinuation { c in
            DispatchQueue.global().async { c.resume(returning: device.downloadFiles(atPaths: [remotePath], toDest: dlDir) { _, _ in }) }
        }
        #expect(dlErr == nil, "download failed")
        let downloaded = try String(contentsOf: dlDir.appendingPathComponent(fileName), encoding: .utf8)
        #expect(downloaded == content, "content mismatch")

        // delete
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            DispatchQueue.global().async { device.deleteFiles(atPaths: [remotePath]); c.resume() }
        }
        files = await withCheckedContinuation { c in
            DispatchQueue.global().async { c.resume(returning: device.listDir(atPath: remoteDir)) }
        }
        #expect(!files.contains { $0.name == fileName }, "file should be deleted")
        print("[+] upload/download/delete passed")
    }

    @Test func renameFile() async throws {
        guard let device = DeviceTestHelpers.getTestDevice() else {
            Issue.record("no authorized device")
            return
        }
        let id = UUID().uuidString.prefix(8)
        let orig = "/sdcard/AxOrig_\(id).txt"
        let renamed = "/sdcard/AxRenamed_\(id).txt"

        // create via push
        let localDir = FileManager.default.temporaryDirectory.appendingPathComponent("AxRename_\(id)")
        try FileManager.default.createDirectory(at: localDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: localDir) }
        let localFile = localDir.appendingPathComponent(RemotePath.lastComponent(orig))
        try "rename test".write(to: localFile, atomically: true, encoding: .utf8)

        _ = await withCheckedContinuation { c in
            DispatchQueue.global().async { c.resume(returning: device.pushFiles(atPaths: [localFile], toDir: "/sdcard") { _, _ in }) }
        }

        // rename
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            DispatchQueue.global().async { device.moveFile(atPath: orig, toPath: renamed); c.resume() }
        }

        let files = await withCheckedContinuation { c in
            DispatchQueue.global().async { c.resume(returning: device.listDir(atPath: "/sdcard")) }
        }
        #expect(!files.contains { $0.name == RemotePath.lastComponent(orig) }, "original should not exist")
        #expect(files.contains { $0.name == RemotePath.lastComponent(renamed) }, "renamed should exist")

        // cleanup
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            DispatchQueue.global().async { device.deleteFiles(atPaths: [renamed]); c.resume() }
        }
        print("[+] rename passed")
    }
}
