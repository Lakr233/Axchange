//
//  JapaneseFilenameTests.swift
//  AxchangeTests
//
//  Created by qaq on 15/12/2025.
//

import Foundation
import Testing

@testable @preconcurrency import Axchange

// MARK: - Japanese Filename Tests (日本語)

@Suite(.serialized)
struct JapaneseFilenameTests {
    @Test func japaneseDakutenNFC() async throws {
        guard let device = DeviceTestHelpers.getTestDevice() else {
            Issue.record("no authorized device")
            return
        }
        // NFC: が ぎ ぐ (precomposed)
        let name = "テスト_\u{304C}\u{304E}\u{3050}_\(UUID().uuidString.prefix(4))"
        let folder = RemotePath.join(dir: "/sdcard", component: name)

        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            DispatchQueue.global().async { device.createFolder(atPath: folder); c.resume() }
        }

        let files = await withCheckedContinuation { c in
            DispatchQueue.global().async { c.resume(returning: device.listDir(atPath: "/sdcard")) }
        }
        let found = files.contains { f in
            f.name == name || f.name.precomposedStringWithCanonicalMapping == name
        }
        #expect(found, "NFC folder should be found")

        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            DispatchQueue.global().async { device.deleteFiles(atPaths: [folder]); c.resume() }
        }
        print("[+] NFC dakuten test passed")
    }

    @Test func japaneseDakutenNFD() async throws {
        guard let device = DeviceTestHelpers.getTestDevice() else {
            Issue.record("no authorized device")
            return
        }
        // NFD: か+゛ き+゛ く+゛ (decomposed)
        let name = "テスト_\u{304B}\u{3099}\u{304D}\u{3099}\u{304F}\u{3099}_\(UUID().uuidString.prefix(4))"
        let folder = RemotePath.join(dir: "/sdcard", component: name)

        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            DispatchQueue.global().async { device.createFolder(atPath: folder); c.resume() }
        }

        let files = await withCheckedContinuation { c in
            DispatchQueue.global().async { c.resume(returning: device.listDir(atPath: "/sdcard")) }
        }
        let found = files.contains { f in
            f.name == name || f.name.decomposedStringWithCanonicalMapping == name
        }
        #expect(found, "NFD folder should be found")

        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            DispatchQueue.global().async { device.deleteFiles(atPaths: [folder]); c.resume() }
        }
        print("[+] NFD dakuten test passed")
    }

    @Test func japaneseFilenameUploadDownload() async throws {
        guard let device = DeviceTestHelpers.getTestDevice() else {
            Issue.record("no authorized device")
            return
        }
        // Issue #5: ダダダ、ぷち、いちご
        let name = "ダダダ_ぷち_いちご_\(UUID().uuidString.prefix(4)).txt"
        let content = "日本語テスト \(Date())"

        let localDir = FileManager.default.temporaryDirectory.appendingPathComponent("AxJP_\(UUID().uuidString.prefix(8))")
        try FileManager.default.createDirectory(at: localDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: localDir) }

        let localFile = localDir.appendingPathComponent(name)
        try content.write(to: localFile, atomically: true, encoding: .utf8)

        let remotePath = RemotePath.join(dir: "/sdcard", component: name)

        // upload
        let err = await withCheckedContinuation { c in
            DispatchQueue.global().async { c.resume(returning: device.pushFiles(atPaths: [localFile], toDir: "/sdcard") { _, _ in }) }
        }
        #expect(err == nil, "upload japanese file failed")

        // verify exists
        let files = await withCheckedContinuation { c in
            DispatchQueue.global().async { c.resume(returning: device.listDir(atPath: "/sdcard")) }
        }
        let found = files.contains { f in
            f.name == name || f.name.precomposedStringWithCanonicalMapping == name.precomposedStringWithCanonicalMapping
        }
        #expect(found, "japanese file should exist on device")

        // download
        let dlDir = localDir.appendingPathComponent("dl")
        try FileManager.default.createDirectory(at: dlDir, withIntermediateDirectories: true)
        let dlErr = await withCheckedContinuation { c in
            DispatchQueue.global().async { c.resume(returning: device.downloadFiles(atPaths: [remotePath], toDest: dlDir) { _, _ in }) }
        }
        #expect(dlErr == nil, "download japanese file failed")

        // find downloaded file (may have different normalization)
        let dlFiles = try FileManager.default.contentsOfDirectory(at: dlDir, includingPropertiesForKeys: nil)
        let dlFile = dlFiles.first { $0.lastPathComponent.precomposedStringWithCanonicalMapping == name.precomposedStringWithCanonicalMapping }
        #expect(dlFile != nil, "downloaded file not found")
        if let dlFile {
            let downloaded = try String(contentsOf: dlFile, encoding: .utf8)
            #expect(downloaded == content, "content mismatch")
        }

        // cleanup
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            DispatchQueue.global().async { device.deleteFiles(atPaths: [remotePath]); c.resume() }
        }
        print("[+] japanese filename upload/download passed")
    }

    @Test func japaneseHiraganaFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "ひらがな_てすと_\(UUID().uuidString.prefix(4)).txt",
            "あいうえお_\(UUID().uuidString.prefix(4)).txt",
            "かきくけこ_\(UUID().uuidString.prefix(4)).txt",
            "さしすせそ_\(UUID().uuidString.prefix(4)).txt",
            "たちつてと_\(UUID().uuidString.prefix(4)).txt",
            "なにぬねの_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] japanese hiragana passed: \(name)")
        }
    }

    @Test func japaneseKatakanaFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "カタカナ_テスト_\(UUID().uuidString.prefix(4)).txt",
            "アイウエオ_\(UUID().uuidString.prefix(4)).txt",
            "ファイル_\(UUID().uuidString.prefix(4)).txt",
            "データ_バックアップ_\(UUID().uuidString.prefix(4)).txt",
            "プログラム_\(UUID().uuidString.prefix(4)).txt",
            "コンピュータ_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] japanese katakana passed: \(name)")
        }
    }

    @Test func japaneseKanjiFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "漢字_試験_\(UUID().uuidString.prefix(4)).txt",
            "日本語_文書_\(UUID().uuidString.prefix(4)).txt",
            "東京_大阪_\(UUID().uuidString.prefix(4)).txt",
            "写真_画像_\(UUID().uuidString.prefix(4)).txt",
            "音楽_動画_\(UUID().uuidString.prefix(4)).txt",
            "仕事_資料_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] japanese kanji passed: \(name)")
        }
    }

    @Test func japaneseMixedScriptFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "テスト_test_测试_\(UUID().uuidString.prefix(4)).txt",
            "ファイル123_\(UUID().uuidString.prefix(4)).txt",
            "日本語English混合_\(UUID().uuidString.prefix(4)).txt",
            "データ_2024年_\(UUID().uuidString.prefix(4)).txt",
            "プロジェクト_v1.0_\(UUID().uuidString.prefix(4)).txt",
            "レポート【最終版】_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] japanese mixed script passed: \(name)")
        }
    }
}
