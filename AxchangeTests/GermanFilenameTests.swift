//
//  GermanFilenameTests.swift
//  AxchangeTests
//
//  Created by qaq on 15/12/2025.
//

import Foundation
import Testing

@testable @preconcurrency import Axchange

// MARK: - German Filename Tests (Deutsch)

@Suite(.serialized)
struct GermanFilenameTests {
    @Test func germanUmlautFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "größe_\(UUID().uuidString.prefix(4)).txt",
            "übung_\(UUID().uuidString.prefix(4)).txt",
            "änderung_\(UUID().uuidString.prefix(4)).txt",
            "öffnen_\(UUID().uuidString.prefix(4)).txt",
            "für_\(UUID().uuidString.prefix(4)).txt",
            "schön_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] german umlaut passed: \(name)")
        }
    }

    @Test func germanEszett() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        // German ß (eszett/sharp s)
        let names = [
            "straße_\(UUID().uuidString.prefix(4)).txt",
            "größe_\(UUID().uuidString.prefix(4)).txt",
            "maß_\(UUID().uuidString.prefix(4)).txt",
            "fuß_\(UUID().uuidString.prefix(4)).txt",
            "gruß_\(UUID().uuidString.prefix(4)).txt",
            "schließen_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] german eszett passed: \(name)")
        }
    }

    @Test func germanCommonWords() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "hallo_welt_\(UUID().uuidString.prefix(4)).txt",
            "danke_schön_\(UUID().uuidString.prefix(4)).txt",
            "guten_morgen_\(UUID().uuidString.prefix(4)).txt",
            "guten_abend_\(UUID().uuidString.prefix(4)).txt",
            "auf_wiedersehen_\(UUID().uuidString.prefix(4)).txt",
            "bitte_schön_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] german common words passed: \(name)")
        }
    }

    @Test func germanNFCAndNFD() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        // NFC (precomposed)
        let nfcNames = [
            "größe_nfc_\(UUID().uuidString.prefix(4)).txt",
            "übung_nfc_\(UUID().uuidString.prefix(4)).txt",
            "änderung_nfc_\(UUID().uuidString.prefix(4)).txt",
            "öffnen_nfc_\(UUID().uuidString.prefix(4)).txt",
            "für_nfc_\(UUID().uuidString.prefix(4)).txt",
            "schön_nfc_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in nfcNames {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] german NFC passed: \(name)")
        }

        // NFD (decomposed) - o + combining umlaut
        let nfdNames = [
            "gro\u{0308}ße_nfd_\(UUID().uuidString.prefix(4)).txt",
            "u\u{0308}bung_nfd_\(UUID().uuidString.prefix(4)).txt",
            "a\u{0308}nderung_nfd_\(UUID().uuidString.prefix(4)).txt",
            "o\u{0308}ffnen_nfd_\(UUID().uuidString.prefix(4)).txt",
            "fu\u{0308}r_nfd_\(UUID().uuidString.prefix(4)).txt",
            "scho\u{0308}n_nfd_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in nfdNames {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] german NFD passed: \(name)")
        }
    }

    @Test func germanCompoundWords() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "Dateiübertragung_\(UUID().uuidString.prefix(4)).txt",
            "Softwareentwicklung_\(UUID().uuidString.prefix(4)).txt",
            "Dokumentenverwaltung_\(UUID().uuidString.prefix(4)).txt",
            "Sicherungskopie_\(UUID().uuidString.prefix(4)).txt",
            "Bildschirmfoto_\(UUID().uuidString.prefix(4)).txt",
            "Arbeitsverzeichnis_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] german compound words passed: \(name)")
        }
    }

    @Test func germanLongFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "dies_ist_ein_sehr_langer_dateiname_für_tests_\(UUID().uuidString.prefix(4)).txt",
            "projekt_dokumentation_sicherung_analyse_\(UUID().uuidString.prefix(4)).txt",
            "softwareentwicklung_programmierung_test_\(UUID().uuidString.prefix(4)).txt",
            "fotoalbum_reise_erinnerungen_sammlung_\(UUID().uuidString.prefix(4)).txt",
            "musikwiedergabeliste_lieblingslieder_\(UUID().uuidString.prefix(4)).txt",
            "arbeit_studium_leben_materialien_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] german long filename passed: \(name)")
        }
    }
}
