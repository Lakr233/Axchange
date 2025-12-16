//
//  FrenchFilenameTests.swift
//  AxchangeTests
//
//  Created by qaq on 15/12/2025.
//

import Foundation
import Testing

@testable @preconcurrency import Axchange

// MARK: - French Filename Tests (Français)

@Suite(.serialized)
struct FrenchFilenameTests {
    @Test func frenchAccentedFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "café_\(UUID().uuidString.prefix(4)).txt",
            "résumé_\(UUID().uuidString.prefix(4)).txt",
            "élève_\(UUID().uuidString.prefix(4)).txt",
            "français_\(UUID().uuidString.prefix(4)).txt",
            "hôtel_\(UUID().uuidString.prefix(4)).txt",
            "naïve_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] french accented passed: \(name)")
        }
    }

    @Test func frenchCommonWords() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "bonjour_monde_\(UUID().uuidString.prefix(4)).txt",
            "document_français_\(UUID().uuidString.prefix(4)).txt",
            "fichier_sauvegarde_\(UUID().uuidString.prefix(4)).txt",
            "projet_développement_\(UUID().uuidString.prefix(4)).txt",
            "photo_souvenir_\(UUID().uuidString.prefix(4)).txt",
            "musique_préférée_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] french common words passed: \(name)")
        }
    }

    @Test func frenchSpecialCharacters() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "ça_va_bien_\(UUID().uuidString.prefix(4)).txt",
            "où_est_le_fichier_\(UUID().uuidString.prefix(4)).txt",
            "à_bientôt_\(UUID().uuidString.prefix(4)).txt",
            "garçon_\(UUID().uuidString.prefix(4)).txt",
            "leçon_\(UUID().uuidString.prefix(4)).txt",
            "façade_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] french special chars passed: \(name)")
        }
    }

    @Test func frenchNFCAndNFD() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        // NFC (precomposed)
        let nfcNames = [
            "café_nfc_\(UUID().uuidString.prefix(4)).txt", // é precomposed
            "résumé_nfc_\(UUID().uuidString.prefix(4)).txt",
            "élève_nfc_\(UUID().uuidString.prefix(4)).txt",
            "hôtel_nfc_\(UUID().uuidString.prefix(4)).txt",
            "naïve_nfc_\(UUID().uuidString.prefix(4)).txt",
            "français_nfc_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in nfcNames {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] french NFC passed: \(name)")
        }

        // NFD (decomposed) - e + combining acute accent
        let nfdNames = [
            "cafe\u{0301}_nfd_\(UUID().uuidString.prefix(4)).txt",
            "re\u{0301}sume\u{0301}_nfd_\(UUID().uuidString.prefix(4)).txt",
            "e\u{0301}le\u{0300}ve_nfd_\(UUID().uuidString.prefix(4)).txt",
            "ho\u{0302}tel_nfd_\(UUID().uuidString.prefix(4)).txt",
            "nai\u{0308}ve_nfd_\(UUID().uuidString.prefix(4)).txt",
            "franc\u{0327}ais_nfd_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in nfdNames {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] french NFD passed: \(name)")
        }
    }

    @Test func frenchPhrases() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "c'est_la_vie_\(UUID().uuidString.prefix(4)).txt",
            "je_t'aime_\(UUID().uuidString.prefix(4)).txt",
            "au_revoir_\(UUID().uuidString.prefix(4)).txt",
            "s'il_vous_plaît_\(UUID().uuidString.prefix(4)).txt",
            "merci_beaucoup_\(UUID().uuidString.prefix(4)).txt",
            "bonne_journée_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] french phrases passed: \(name)")
        }
    }
}
