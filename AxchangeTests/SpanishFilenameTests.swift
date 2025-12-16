//
//  SpanishFilenameTests.swift
//  AxchangeTests
//
//  Created by qaq on 15/12/2025.
//

import Foundation
import Testing

@testable @preconcurrency import Axchange

// MARK: - Spanish Filename Tests (Español)

@Suite(.serialized)
struct SpanishFilenameTests {
    @Test func spanishAccentedFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "español_\(UUID().uuidString.prefix(4)).txt",
            "información_\(UUID().uuidString.prefix(4)).txt",
            "música_\(UUID().uuidString.prefix(4)).txt",
            "fotografía_\(UUID().uuidString.prefix(4)).txt",
            "comunicación_\(UUID().uuidString.prefix(4)).txt",
            "educación_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] spanish accented passed: \(name)")
        }
    }

    @Test func spanishWithEne() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "año_\(UUID().uuidString.prefix(4)).txt",
            "niño_\(UUID().uuidString.prefix(4)).txt",
            "señor_\(UUID().uuidString.prefix(4)).txt",
            "mañana_\(UUID().uuidString.prefix(4)).txt",
            "España_\(UUID().uuidString.prefix(4)).txt",
            "pequeño_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] spanish with ñ passed: \(name)")
        }
    }

    @Test func spanishCommonWords() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "hola_mundo_\(UUID().uuidString.prefix(4)).txt",
            "documento_\(UUID().uuidString.prefix(4)).txt",
            "archivo_respaldo_\(UUID().uuidString.prefix(4)).txt",
            "proyecto_desarrollo_\(UUID().uuidString.prefix(4)).txt",
            "imagen_recuerdo_\(UUID().uuidString.prefix(4)).txt",
            "canción_favorita_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] spanish common words passed: \(name)")
        }
    }

    @Test func spanishQuestionExclamation() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "¿qué_tal_\(UUID().uuidString.prefix(4)).txt",
            "¡hola_\(UUID().uuidString.prefix(4)).txt",
            "¿cómo_estás_\(UUID().uuidString.prefix(4)).txt",
            "¡felicidades_\(UUID().uuidString.prefix(4)).txt",
            "¿dónde_está_\(UUID().uuidString.prefix(4)).txt",
            "¡gracias_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] spanish question/exclamation passed: \(name)")
        }
    }

    @Test func spanishPhrases() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "buenos_días_\(UUID().uuidString.prefix(4)).txt",
            "buenas_noches_\(UUID().uuidString.prefix(4)).txt",
            "hasta_luego_\(UUID().uuidString.prefix(4)).txt",
            "por_favor_\(UUID().uuidString.prefix(4)).txt",
            "muchas_gracias_\(UUID().uuidString.prefix(4)).txt",
            "de_nada_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] spanish phrases passed: \(name)")
        }
    }

    @Test func spanishNFCAndNFD() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        // NFC (precomposed)
        let nfcNames = [
            "español_nfc_\(UUID().uuidString.prefix(4)).txt",
            "información_nfc_\(UUID().uuidString.prefix(4)).txt",
            "música_nfc_\(UUID().uuidString.prefix(4)).txt",
            "año_nfc_\(UUID().uuidString.prefix(4)).txt",
            "niño_nfc_\(UUID().uuidString.prefix(4)).txt",
            "señor_nfc_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in nfcNames {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] spanish NFC passed: \(name)")
        }

        // NFD (decomposed)
        let nfdNames = [
            "espan\u{0303}ol_nfd_\(UUID().uuidString.prefix(4)).txt",
            "informacio\u{0301}n_nfd_\(UUID().uuidString.prefix(4)).txt",
            "mu\u{0301}sica_nfd_\(UUID().uuidString.prefix(4)).txt",
            "an\u{0303}o_nfd_\(UUID().uuidString.prefix(4)).txt",
            "nin\u{0303}o_nfd_\(UUID().uuidString.prefix(4)).txt",
            "sen\u{0303}or_nfd_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in nfdNames {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] spanish NFD passed: \(name)")
        }
    }
}
