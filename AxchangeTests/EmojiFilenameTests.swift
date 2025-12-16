//
//  EmojiFilenameTests.swift
//  AxchangeTests
//
//  Created by qaq on 15/12/2025.
//

import Foundation
import Testing

@testable @preconcurrency import Axchange

// MARK: - Emoji Filename Tests

@Suite(.serialized)
struct EmojiFilenameTests {
    @Test func emojiBasicFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "📦_package_\(UUID().uuidString.prefix(4)).txt",
            "📄_document_\(UUID().uuidString.prefix(4)).txt",
            "🎵_music_\(UUID().uuidString.prefix(4)).txt",
            "📷_photo_\(UUID().uuidString.prefix(4)).txt",
            "🎬_video_\(UUID().uuidString.prefix(4)).txt",
            "💾_backup_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] emoji basic passed: \(name)")
        }
    }

    @Test func emojiMultipleInFilename() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "📦📄📁_files_\(UUID().uuidString.prefix(4)).txt",
            "🎵🎶🎧_music_\(UUID().uuidString.prefix(4)).txt",
            "📷🖼️🎨_images_\(UUID().uuidString.prefix(4)).txt",
            "💻🖥️⌨️_computer_\(UUID().uuidString.prefix(4)).txt",
            "🌍🌎🌏_world_\(UUID().uuidString.prefix(4)).txt",
            "⭐🌟✨_stars_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] emoji multiple passed: \(name)")
        }
    }

    @Test func emojiWithSkinTones() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        // Emoji with skin tone modifiers (ZWJ sequences)
        let names = [
            "👋🏻_wave_light_\(UUID().uuidString.prefix(4)).txt",
            "👋🏼_wave_medlight_\(UUID().uuidString.prefix(4)).txt",
            "👋🏽_wave_medium_\(UUID().uuidString.prefix(4)).txt",
            "👋🏾_wave_meddark_\(UUID().uuidString.prefix(4)).txt",
            "👋🏿_wave_dark_\(UUID().uuidString.prefix(4)).txt",
            "🧑🏻‍💻_dev_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] emoji skin tones passed: \(name)")
        }
    }

    @Test func emojiFlags() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        // Flag emoji (regional indicator sequences)
        let names = [
            "🇺🇸_usa_\(UUID().uuidString.prefix(4)).txt",
            "🇯🇵_japan_\(UUID().uuidString.prefix(4)).txt",
            "🇨🇳_china_\(UUID().uuidString.prefix(4)).txt",
            "🇫🇷_france_\(UUID().uuidString.prefix(4)).txt",
            "🇩🇪_germany_\(UUID().uuidString.prefix(4)).txt",
            "🇧🇷_brazil_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] emoji flags passed: \(name)")
        }
    }

    @Test func emojiZWJSequences() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        // Complex ZWJ (Zero Width Joiner) sequences
        let names = [
            "👨‍👩‍👧‍👦_family_\(UUID().uuidString.prefix(4)).txt",
            "👩‍💻_woman_dev_\(UUID().uuidString.prefix(4)).txt",
            "👨‍🍳_man_cook_\(UUID().uuidString.prefix(4)).txt",
            "🏳️‍🌈_rainbow_\(UUID().uuidString.prefix(4)).txt",
            "👩‍❤️‍👨_couple_\(UUID().uuidString.prefix(4)).txt",
            "🧑‍🤝‍🧑_people_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] emoji ZWJ sequences passed: \(name)")
        }
    }

    @Test func emojiMixedWithText() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "test_📦_file_\(UUID().uuidString.prefix(4)).txt",
            "my_🎵_playlist_\(UUID().uuidString.prefix(4)).txt",
            "vacation_📷_photos_\(UUID().uuidString.prefix(4)).txt",
            "project_💻_code_\(UUID().uuidString.prefix(4)).txt",
            "backup_💾_data_\(UUID().uuidString.prefix(4)).txt",
            "notes_📝_meeting_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] emoji mixed text passed: \(name)")
        }
    }

    @Test func emojiMixedWithMultipleLanguages() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "测试_📦_test_\(UUID().uuidString.prefix(4)).txt",
            "テスト_🎵_música_\(UUID().uuidString.prefix(4)).txt",
            "тест_📷_foto_\(UUID().uuidString.prefix(4)).txt",
            "اختبار_💻_code_\(UUID().uuidString.prefix(4)).txt",
            "한글_💾_backup_\(UUID().uuidString.prefix(4)).txt",
            "ไทย_📝_notes_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] emoji mixed languages passed: \(name)")
        }
    }
}
