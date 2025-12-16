//
//  EnglishFilenameTests.swift
//  AxchangeTests
//
//  Created by qaq on 15/12/2025.
//

import Foundation
import Testing

@testable @preconcurrency import Axchange

// MARK: - English Filename Tests

@Suite(.serialized)
struct EnglishFilenameTests {
    @Test func englishBasicFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "test_file_\(UUID().uuidString.prefix(4)).txt",
            "document_\(UUID().uuidString.prefix(4)).txt",
            "backup_data_\(UUID().uuidString.prefix(4)).txt",
            "project_report_\(UUID().uuidString.prefix(4)).txt",
            "image_photo_\(UUID().uuidString.prefix(4)).txt",
            "music_audio_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] english basic passed: \(name)")
        }
    }

    @Test func englishWithSpaces() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "test file with spaces_\(UUID().uuidString.prefix(4)).txt",
            "my document_\(UUID().uuidString.prefix(4)).txt",
            "project report final_\(UUID().uuidString.prefix(4)).txt",
            "backup data 2024_\(UUID().uuidString.prefix(4)).txt",
            "photo album vacation_\(UUID().uuidString.prefix(4)).txt",
            "music playlist summer_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] english with spaces passed: \(name)")
        }
    }

    @Test func englishCamelCase() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "TestFile_\(UUID().uuidString.prefix(4)).txt",
            "MyDocument_\(UUID().uuidString.prefix(4)).txt",
            "ProjectReport_\(UUID().uuidString.prefix(4)).txt",
            "BackupData_\(UUID().uuidString.prefix(4)).txt",
            "PhotoAlbum_\(UUID().uuidString.prefix(4)).txt",
            "MusicPlaylist_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] english camelCase passed: \(name)")
        }
    }

    @Test func englishWithNumbers() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "file001_\(UUID().uuidString.prefix(4)).txt",
            "document_v2.0_\(UUID().uuidString.prefix(4)).txt",
            "backup_2024_12_15_\(UUID().uuidString.prefix(4)).txt",
            "report_chapter1_\(UUID().uuidString.prefix(4)).txt",
            "image_1920x1080_\(UUID().uuidString.prefix(4)).txt",
            "audio_320kbps_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] english with numbers passed: \(name)")
        }
    }

    @Test func englishSpecialCharacters() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "file-with-dashes_\(UUID().uuidString.prefix(4)).txt",
            "file.with.dots_\(UUID().uuidString.prefix(4)).txt",
            "file_with_underscores_\(UUID().uuidString.prefix(4)).txt",
            "file(with)parens_\(UUID().uuidString.prefix(4)).txt",
            "file[with]brackets_\(UUID().uuidString.prefix(4)).txt",
            "file+plus+sign_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] english special chars passed: \(name)")
        }
    }

    @Test func englishLongFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "this_is_a_very_long_filename_for_testing_purposes_\(UUID().uuidString.prefix(4)).txt",
            "project_documentation_backup_final_version_\(UUID().uuidString.prefix(4)).txt",
            "software_development_source_code_repository_\(UUID().uuidString.prefix(4)).txt",
            "photo_album_vacation_summer_2024_memories_\(UUID().uuidString.prefix(4)).txt",
            "music_playlist_favorite_songs_collection_\(UUID().uuidString.prefix(4)).txt",
            "work_documents_meeting_notes_archive_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] english long filename passed: \(name)")
        }
    }
}
