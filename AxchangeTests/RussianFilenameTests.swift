//
//  RussianFilenameTests.swift
//  AxchangeTests
//
//  Created by qaq on 15/12/2025.
//

import Foundation
import Testing

@testable @preconcurrency import Axchange

// MARK: - Russian Filename Tests (Русский)

@Suite(.serialized)
struct RussianFilenameTests {
    @Test func russianBasicFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "тест_\(UUID().uuidString.prefix(4)).txt",
            "файл_\(UUID().uuidString.prefix(4)).txt",
            "документ_\(UUID().uuidString.prefix(4)).txt",
            "проект_\(UUID().uuidString.prefix(4)).txt",
            "фото_\(UUID().uuidString.prefix(4)).txt",
            "музыка_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] russian basic passed: \(name)")
        }
    }

    @Test func russianCommonWords() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "привет_мир_\(UUID().uuidString.prefix(4)).txt",
            "спасибо_\(UUID().uuidString.prefix(4)).txt",
            "пожалуйста_\(UUID().uuidString.prefix(4)).txt",
            "доброе_утро_\(UUID().uuidString.prefix(4)).txt",
            "добрый_вечер_\(UUID().uuidString.prefix(4)).txt",
            "спокойной_ночи_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] russian common words passed: \(name)")
        }
    }

    @Test func russianWithYo() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        // Russian ё (yo) character
        let names = [
            "ёлка_\(UUID().uuidString.prefix(4)).txt",
            "ёж_\(UUID().uuidString.prefix(4)).txt",
            "всё_\(UUID().uuidString.prefix(4)).txt",
            "её_\(UUID().uuidString.prefix(4)).txt",
            "моё_\(UUID().uuidString.prefix(4)).txt",
            "твоё_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] russian with ё passed: \(name)")
        }
    }

    @Test func russianMixedWithEnglish() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "тест_test_\(UUID().uuidString.prefix(4)).txt",
            "файл_file_\(UUID().uuidString.prefix(4)).txt",
            "документ_document_\(UUID().uuidString.prefix(4)).txt",
            "проект_project_\(UUID().uuidString.prefix(4)).txt",
            "данные_data_\(UUID().uuidString.prefix(4)).txt",
            "резервная_backup_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] russian mixed english passed: \(name)")
        }
    }

    @Test func russianWithNumbers() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "файл_2024_\(UUID().uuidString.prefix(4)).txt",
            "глава_1_введение_\(UUID().uuidString.prefix(4)).txt",
            "отчёт_v2.0_\(UUID().uuidString.prefix(4)).txt",
            "данные_123_\(UUID().uuidString.prefix(4)).txt",
            "проект_001_\(UUID().uuidString.prefix(4)).txt",
            "тест_99_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] russian with numbers passed: \(name)")
        }
    }

    @Test func russianLongFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "это_очень_длинное_имя_файла_для_теста_\(UUID().uuidString.prefix(4)).txt",
            "проект_документы_резервная_копия_анализ_\(UUID().uuidString.prefix(4)).txt",
            "разработка_программного_обеспечения_тест_\(UUID().uuidString.prefix(4)).txt",
            "фотоальбом_путешествие_воспоминания_\(UUID().uuidString.prefix(4)).txt",
            "плейлист_любимые_песни_коллекция_\(UUID().uuidString.prefix(4)).txt",
            "работа_учёба_жизнь_материалы_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] russian long filename passed: \(name)")
        }
    }
}
