//
//  KoreanFilenameTests.swift
//  AxchangeTests
//
//  Created by qaq on 15/12/2025.
//

import Foundation
import Testing

@testable @preconcurrency import Axchange

// MARK: - Korean Filename Tests (한국어)

@Suite(.serialized)
struct KoreanFilenameTests {
    @Test func koreanBasicFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "한글_테스트_\(UUID().uuidString.prefix(4)).txt",
            "파일_이름_\(UUID().uuidString.prefix(4)).txt",
            "문서_백업_\(UUID().uuidString.prefix(4)).txt",
            "프로젝트_\(UUID().uuidString.prefix(4)).txt",
            "사진_앨범_\(UUID().uuidString.prefix(4)).txt",
            "음악_재생목록_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] korean basic passed: \(name)")
        }
    }

    @Test func koreanCommonWords() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "안녕하세요_\(UUID().uuidString.prefix(4)).txt",
            "감사합니다_\(UUID().uuidString.prefix(4)).txt",
            "대한민국_\(UUID().uuidString.prefix(4)).txt",
            "서울_부산_\(UUID().uuidString.prefix(4)).txt",
            "컴퓨터_소프트웨어_\(UUID().uuidString.prefix(4)).txt",
            "인터넷_네트워크_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] korean common words passed: \(name)")
        }
    }

    @Test func koreanMixedWithEnglish() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "테스트_test_\(UUID().uuidString.prefix(4)).txt",
            "파일_file_\(UUID().uuidString.prefix(4)).txt",
            "문서_document_\(UUID().uuidString.prefix(4)).txt",
            "프로젝트_project_\(UUID().uuidString.prefix(4)).txt",
            "데이터_data_\(UUID().uuidString.prefix(4)).txt",
            "백업_backup_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] korean mixed english passed: \(name)")
        }
    }

    @Test func koreanWithNumbers() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "파일_2024_\(UUID().uuidString.prefix(4)).txt",
            "제1장_소개_\(UUID().uuidString.prefix(4)).txt",
            "보고서_v2.0_\(UUID().uuidString.prefix(4)).txt",
            "데이터_123_\(UUID().uuidString.prefix(4)).txt",
            "프로젝트_001_\(UUID().uuidString.prefix(4)).txt",
            "테스트_99_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] korean with numbers passed: \(name)")
        }
    }

    @Test func koreanJamoDecomposed() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        // Korean can have composed (NFC) and decomposed (NFD) forms
        // NFC: 한 (single character)
        // NFD: ㅎ + ㅏ + ㄴ (jamo)
        let names = [
            "한글_nfc_\(UUID().uuidString.prefix(4)).txt",
            "테스트_nfc_\(UUID().uuidString.prefix(4)).txt",
            "파일_nfc_\(UUID().uuidString.prefix(4)).txt",
            "문서_nfc_\(UUID().uuidString.prefix(4)).txt",
            "프로젝트_nfc_\(UUID().uuidString.prefix(4)).txt",
            "데이터_nfc_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] korean jamo passed: \(name)")
        }
    }

    @Test func koreanLongFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "이것은_매우_긴_한글_파일_이름입니다_\(UUID().uuidString.prefix(4)).txt",
            "프로젝트_문서_백업_자료_분석_보고서_\(UUID().uuidString.prefix(4)).txt",
            "소프트웨어_개발_프로그램_테스트_파일_\(UUID().uuidString.prefix(4)).txt",
            "사진_앨범_여행_추억_모음_\(UUID().uuidString.prefix(4)).txt",
            "음악_재생목록_좋아하는_노래_\(UUID().uuidString.prefix(4)).txt",
            "업무_학습_생활_자료_정리_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] korean long filename passed: \(name)")
        }
    }
}
