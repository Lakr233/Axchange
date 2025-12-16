//
//  PortugueseFilenameTests.swift
//  AxchangeTests
//
//  Created by qaq on 15/12/2025.
//

import Foundation
import Testing

@testable @preconcurrency import Axchange

// MARK: - Portuguese Filename Tests (Português)

@Suite(.serialized)
struct PortugueseFilenameTests {
    @Test func portugueseAccentedFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "português_\(UUID().uuidString.prefix(4)).txt",
            "informação_\(UUID().uuidString.prefix(4)).txt",
            "música_\(UUID().uuidString.prefix(4)).txt",
            "coração_\(UUID().uuidString.prefix(4)).txt",
            "ação_\(UUID().uuidString.prefix(4)).txt",
            "educação_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] portuguese accented passed: \(name)")
        }
    }

    @Test func portugueseTildeFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        // Portuguese ã and õ
        let names = [
            "não_\(UUID().uuidString.prefix(4)).txt",
            "são_\(UUID().uuidString.prefix(4)).txt",
            "mão_\(UUID().uuidString.prefix(4)).txt",
            "pão_\(UUID().uuidString.prefix(4)).txt",
            "avião_\(UUID().uuidString.prefix(4)).txt",
            "limão_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] portuguese tilde passed: \(name)")
        }
    }

    @Test func portugueseCommonWords() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "olá_mundo_\(UUID().uuidString.prefix(4)).txt",
            "obrigado_\(UUID().uuidString.prefix(4)).txt",
            "bom_dia_\(UUID().uuidString.prefix(4)).txt",
            "boa_noite_\(UUID().uuidString.prefix(4)).txt",
            "até_logo_\(UUID().uuidString.prefix(4)).txt",
            "por_favor_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] portuguese common words passed: \(name)")
        }
    }

    @Test func portugueseNFCAndNFD() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        // NFC (precomposed)
        let nfcNames = [
            "português_nfc_\(UUID().uuidString.prefix(4)).txt",
            "informação_nfc_\(UUID().uuidString.prefix(4)).txt",
            "coração_nfc_\(UUID().uuidString.prefix(4)).txt",
            "não_nfc_\(UUID().uuidString.prefix(4)).txt",
            "são_nfc_\(UUID().uuidString.prefix(4)).txt",
            "avião_nfc_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in nfcNames {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] portuguese NFC passed: \(name)")
        }

        // NFD (decomposed)
        let nfdNames = [
            "portugue\u{0302}s_nfd_\(UUID().uuidString.prefix(4)).txt",
            "informac\u{0327}a\u{0303}o_nfd_\(UUID().uuidString.prefix(4)).txt",
            "corac\u{0327}a\u{0303}o_nfd_\(UUID().uuidString.prefix(4)).txt",
            "na\u{0303}o_nfd_\(UUID().uuidString.prefix(4)).txt",
            "sa\u{0303}o_nfd_\(UUID().uuidString.prefix(4)).txt",
            "avia\u{0303}o_nfd_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in nfdNames {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] portuguese NFD passed: \(name)")
        }
    }

    @Test func portugueseBrazilianVariant() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "Brasil_\(UUID().uuidString.prefix(4)).txt",
            "São_Paulo_\(UUID().uuidString.prefix(4)).txt",
            "Rio_de_Janeiro_\(UUID().uuidString.prefix(4)).txt",
            "Brasília_\(UUID().uuidString.prefix(4)).txt",
            "café_brasileiro_\(UUID().uuidString.prefix(4)).txt",
            "futebol_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] portuguese brazilian passed: \(name)")
        }
    }

    @Test func portugueseLongFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "este_é_um_nome_de_arquivo_muito_longo_\(UUID().uuidString.prefix(4)).txt",
            "projeto_documentação_backup_análise_\(UUID().uuidString.prefix(4)).txt",
            "desenvolvimento_software_programação_\(UUID().uuidString.prefix(4)).txt",
            "álbum_fotos_viagem_memórias_\(UUID().uuidString.prefix(4)).txt",
            "lista_músicas_favoritas_coleção_\(UUID().uuidString.prefix(4)).txt",
            "trabalho_estudo_vida_materiais_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] portuguese long filename passed: \(name)")
        }
    }
}
