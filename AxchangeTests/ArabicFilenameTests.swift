//
//  ArabicFilenameTests.swift
//  AxchangeTests
//
//  Created by qaq on 15/12/2025.
//

import Foundation
import Testing

@testable @preconcurrency import Axchange

// MARK: - Arabic Filename Tests (العربية)

@Suite(.serialized)
struct ArabicFilenameTests {
    @Test func arabicBasicFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "اختبار_\(UUID().uuidString.prefix(4)).txt",
            "ملف_\(UUID().uuidString.prefix(4)).txt",
            "مستند_\(UUID().uuidString.prefix(4)).txt",
            "مشروع_\(UUID().uuidString.prefix(4)).txt",
            "صورة_\(UUID().uuidString.prefix(4)).txt",
            "موسيقى_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] arabic basic passed: \(name)")
        }
    }

    @Test func arabicCommonWords() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "مرحبا_بالعالم_\(UUID().uuidString.prefix(4)).txt",
            "شكرا_جزيلا_\(UUID().uuidString.prefix(4)).txt",
            "السلام_عليكم_\(UUID().uuidString.prefix(4)).txt",
            "صباح_الخير_\(UUID().uuidString.prefix(4)).txt",
            "مساء_الخير_\(UUID().uuidString.prefix(4)).txt",
            "تصبح_على_خير_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] arabic common words passed: \(name)")
        }
    }

    @Test func arabicWithDiacritics() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        // Arabic with tashkeel (diacritical marks)
        let names = [
            "كِتَاب_\(UUID().uuidString.prefix(4)).txt",
            "قَلَم_\(UUID().uuidString.prefix(4)).txt",
            "مَدْرَسَة_\(UUID().uuidString.prefix(4)).txt",
            "جَامِعَة_\(UUID().uuidString.prefix(4)).txt",
            "حَاسُوب_\(UUID().uuidString.prefix(4)).txt",
            "بَرْنَامَج_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] arabic with diacritics passed: \(name)")
        }
    }

    @Test func arabicMixedWithEnglish() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "اختبار_test_\(UUID().uuidString.prefix(4)).txt",
            "ملف_file_\(UUID().uuidString.prefix(4)).txt",
            "مستند_document_\(UUID().uuidString.prefix(4)).txt",
            "مشروع_project_\(UUID().uuidString.prefix(4)).txt",
            "بيانات_data_\(UUID().uuidString.prefix(4)).txt",
            "نسخة_backup_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] arabic mixed english passed: \(name)")
        }
    }

    @Test func arabicWithNumbers() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "ملف_2024_\(UUID().uuidString.prefix(4)).txt",
            "الفصل_1_مقدمة_\(UUID().uuidString.prefix(4)).txt",
            "تقرير_v2.0_\(UUID().uuidString.prefix(4)).txt",
            "بيانات_123_\(UUID().uuidString.prefix(4)).txt",
            "مشروع_001_\(UUID().uuidString.prefix(4)).txt",
            "اختبار_99_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] arabic with numbers passed: \(name)")
        }
    }

    @Test func arabicLongFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "هذا_اسم_ملف_طويل_جدا_للاختبار_\(UUID().uuidString.prefix(4)).txt",
            "مشروع_وثائق_نسخة_احتياطية_تحليل_\(UUID().uuidString.prefix(4)).txt",
            "تطوير_برمجيات_برنامج_اختبار_\(UUID().uuidString.prefix(4)).txt",
            "ألبوم_صور_رحلة_ذكريات_\(UUID().uuidString.prefix(4)).txt",
            "قائمة_موسيقى_أغاني_مفضلة_\(UUID().uuidString.prefix(4)).txt",
            "عمل_دراسة_حياة_مواد_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] arabic long filename passed: \(name)")
        }
    }
}
