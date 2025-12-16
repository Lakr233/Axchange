//
//  ThaiFilenameTests.swift
//  AxchangeTests
//
//  Created by qaq on 15/12/2025.
//

import Foundation
import Testing

@testable @preconcurrency import Axchange

// MARK: - Thai Filename Tests (ภาษาไทย)

@Suite(.serialized)
struct ThaiFilenameTests {
    @Test func thaiBasicFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "ทดสอบ_\(UUID().uuidString.prefix(4)).txt",
            "ไฟล์_\(UUID().uuidString.prefix(4)).txt",
            "เอกสาร_\(UUID().uuidString.prefix(4)).txt",
            "โครงการ_\(UUID().uuidString.prefix(4)).txt",
            "รูปภาพ_\(UUID().uuidString.prefix(4)).txt",
            "เพลง_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] thai basic passed: \(name)")
        }
    }

    @Test func thaiCommonWords() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "สวัสดี_โลก_\(UUID().uuidString.prefix(4)).txt",
            "ขอบคุณ_\(UUID().uuidString.prefix(4)).txt",
            "สวัสดีตอนเช้า_\(UUID().uuidString.prefix(4)).txt",
            "สวัสดีตอนเย็น_\(UUID().uuidString.prefix(4)).txt",
            "ลาก่อน_\(UUID().uuidString.prefix(4)).txt",
            "กรุณา_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] thai common words passed: \(name)")
        }
    }

    @Test func thaiWithToneMarks() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        // Thai with tone marks (่ ้ ๊ ๋)
        let names = [
            "น้ำ_\(UUID().uuidString.prefix(4)).txt",
            "ก้าว_\(UUID().uuidString.prefix(4)).txt",
            "ม้า_\(UUID().uuidString.prefix(4)).txt",
            "ข้าว_\(UUID().uuidString.prefix(4)).txt",
            "เสื้อ_\(UUID().uuidString.prefix(4)).txt",
            "เมื่อ_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] thai with tone marks passed: \(name)")
        }
    }

    @Test func thaiMixedWithEnglish() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "ทดสอบ_test_\(UUID().uuidString.prefix(4)).txt",
            "ไฟล์_file_\(UUID().uuidString.prefix(4)).txt",
            "เอกสาร_document_\(UUID().uuidString.prefix(4)).txt",
            "โครงการ_project_\(UUID().uuidString.prefix(4)).txt",
            "ข้อมูล_data_\(UUID().uuidString.prefix(4)).txt",
            "สำรอง_backup_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] thai mixed english passed: \(name)")
        }
    }

    @Test func thaiWithNumbers() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "ไฟล์_2024_\(UUID().uuidString.prefix(4)).txt",
            "บท_1_บทนำ_\(UUID().uuidString.prefix(4)).txt",
            "รายงาน_v2.0_\(UUID().uuidString.prefix(4)).txt",
            "ข้อมูล_123_\(UUID().uuidString.prefix(4)).txt",
            "โครงการ_001_\(UUID().uuidString.prefix(4)).txt",
            "ทดสอบ_99_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] thai with numbers passed: \(name)")
        }
    }

    @Test func thaiLongFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "นี่คือชื่อไฟล์ที่ยาวมากสำหรับการทดสอบ_\(UUID().uuidString.prefix(4)).txt",
            "โครงการเอกสารสำรองข้อมูลวิเคราะห์_\(UUID().uuidString.prefix(4)).txt",
            "พัฒนาซอฟต์แวร์โปรแกรมทดสอบ_\(UUID().uuidString.prefix(4)).txt",
            "อัลบั้มรูปภาพท่องเที่ยวความทรงจำ_\(UUID().uuidString.prefix(4)).txt",
            "รายการเพลงโปรดคอลเลกชัน_\(UUID().uuidString.prefix(4)).txt",
            "งานเรียนชีวิตวัสดุ_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] thai long filename passed: \(name)")
        }
    }
}
