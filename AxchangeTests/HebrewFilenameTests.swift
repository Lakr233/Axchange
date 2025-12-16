//
//  HebrewFilenameTests.swift
//  AxchangeTests
//
//  Created by qaq on 15/12/2025.
//

import Foundation
import Testing

@testable @preconcurrency import Axchange

// MARK: - Hebrew Filename Tests (עברית)

@Suite(.serialized)
struct HebrewFilenameTests {
    @Test func hebrewBasicFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "בדיקה_\(UUID().uuidString.prefix(4)).txt",
            "קובץ_\(UUID().uuidString.prefix(4)).txt",
            "מסמך_\(UUID().uuidString.prefix(4)).txt",
            "פרויקט_\(UUID().uuidString.prefix(4)).txt",
            "תמונה_\(UUID().uuidString.prefix(4)).txt",
            "מוזיקה_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] hebrew basic passed: \(name)")
        }
    }

    @Test func hebrewCommonWords() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "שלום_עולם_\(UUID().uuidString.prefix(4)).txt",
            "תודה_רבה_\(UUID().uuidString.prefix(4)).txt",
            "בוקר_טוב_\(UUID().uuidString.prefix(4)).txt",
            "ערב_טוב_\(UUID().uuidString.prefix(4)).txt",
            "להתראות_\(UUID().uuidString.prefix(4)).txt",
            "בבקשה_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] hebrew common words passed: \(name)")
        }
    }

    @Test func hebrewWithNiqqud() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        // Hebrew with vowel points (niqqud)
        let names = [
            "שָׁלוֹם_\(UUID().uuidString.prefix(4)).txt",
            "בְּרָכָה_\(UUID().uuidString.prefix(4)).txt",
            "תּוֹדָה_\(UUID().uuidString.prefix(4)).txt",
            "אֱמֶת_\(UUID().uuidString.prefix(4)).txt",
            "חַיִּים_\(UUID().uuidString.prefix(4)).txt",
            "אַהֲבָה_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] hebrew with niqqud passed: \(name)")
        }
    }

    @Test func hebrewMixedWithEnglish() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "בדיקה_test_\(UUID().uuidString.prefix(4)).txt",
            "קובץ_file_\(UUID().uuidString.prefix(4)).txt",
            "מסמך_document_\(UUID().uuidString.prefix(4)).txt",
            "פרויקט_project_\(UUID().uuidString.prefix(4)).txt",
            "נתונים_data_\(UUID().uuidString.prefix(4)).txt",
            "גיבוי_backup_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] hebrew mixed english passed: \(name)")
        }
    }

    @Test func hebrewWithNumbers() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "קובץ_2024_\(UUID().uuidString.prefix(4)).txt",
            "פרק_1_מבוא_\(UUID().uuidString.prefix(4)).txt",
            "דוח_v2.0_\(UUID().uuidString.prefix(4)).txt",
            "נתונים_123_\(UUID().uuidString.prefix(4)).txt",
            "פרויקט_001_\(UUID().uuidString.prefix(4)).txt",
            "בדיקה_99_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] hebrew with numbers passed: \(name)")
        }
    }

    @Test func hebrewLongFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "זהו_שם_קובץ_ארוך_מאוד_לבדיקה_\(UUID().uuidString.prefix(4)).txt",
            "פרויקט_מסמכים_גיבוי_ניתוח_\(UUID().uuidString.prefix(4)).txt",
            "פיתוח_תוכנה_תכנות_בדיקה_\(UUID().uuidString.prefix(4)).txt",
            "אלבום_תמונות_טיול_זיכרונות_\(UUID().uuidString.prefix(4)).txt",
            "רשימת_שירים_אהובים_אוסף_\(UUID().uuidString.prefix(4)).txt",
            "עבודה_לימודים_חיים_חומרים_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] hebrew long filename passed: \(name)")
        }
    }
}
