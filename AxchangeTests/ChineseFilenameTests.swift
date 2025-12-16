//
//  ChineseFilenameTests.swift
//  AxchangeTests
//
//  Created by qaq on 15/12/2025.
//

import Foundation
import Testing

@testable @preconcurrency import Axchange

// MARK: - Chinese Filename Tests (中文)

@Suite(.serialized)
struct ChineseFilenameTests {
    @Test func chineseSimplifiedFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "中文测试_\(UUID().uuidString.prefix(4)).txt",
            "简体中文_文件名_\(UUID().uuidString.prefix(4)).txt",
            "你好世界_\(UUID().uuidString.prefix(4)).txt",
            "数据文件_备份_\(UUID().uuidString.prefix(4)).txt",
            "程序设计_代码_\(UUID().uuidString.prefix(4)).txt",
            "图片_照片_相册_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] chinese simplified passed: \(name)")
        }
    }

    @Test func chineseTraditionalFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "繁體中文_測試_\(UUID().uuidString.prefix(4)).txt",
            "檔案名稱_\(UUID().uuidString.prefix(4)).txt",
            "資料夾_備份_\(UUID().uuidString.prefix(4)).txt",
            "程式設計_\(UUID().uuidString.prefix(4)).txt",
            "圖片_相簿_\(UUID().uuidString.prefix(4)).txt",
            "電腦_軟體_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] chinese traditional passed: \(name)")
        }
    }

    @Test func chineseMixedWithNumbers() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "文件2024_\(UUID().uuidString.prefix(4)).txt",
            "第1章_介绍_\(UUID().uuidString.prefix(4)).txt",
            "报告_v2.0_\(UUID().uuidString.prefix(4)).txt",
            "数据_123_备份_\(UUID().uuidString.prefix(4)).txt",
            "项目_001_文档_\(UUID().uuidString.prefix(4)).txt",
            "测试_99_结果_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] chinese mixed numbers passed: \(name)")
        }
    }

    @Test func chineseSpecialCharacters() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "文件【重要】_\(UUID().uuidString.prefix(4)).txt",
            "资料（备份）_\(UUID().uuidString.prefix(4)).txt",
            "项目「测试」_\(UUID().uuidString.prefix(4)).txt",
            "数据『分析』_\(UUID().uuidString.prefix(4)).txt",
            "报告——最终版_\(UUID().uuidString.prefix(4)).txt",
            "文档…续_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] chinese special chars passed: \(name)")
        }
    }

    @Test func chineseLongFilenames() async throws {
        guard let device = DeviceTestHelpers.requireTestDevice() else { return }

        let names = [
            "这是一个非常长的中文文件名用于测试_\(UUID().uuidString.prefix(4)).txt",
            "项目文档备份资料数据分析报告_\(UUID().uuidString.prefix(4)).txt",
            "软件开发程序设计代码测试文件_\(UUID().uuidString.prefix(4)).txt",
            "图片照片相册视频音乐文件夹_\(UUID().uuidString.prefix(4)).txt",
            "工作学习生活娱乐资料整理_\(UUID().uuidString.prefix(4)).txt",
            "北京上海广州深圳杭州成都_\(UUID().uuidString.prefix(4)).txt",
        ]

        for name in names {
            try await DeviceTestHelpers.assertUploadDownloadOverwriteRenameDelete(device: device, fileName: name)
            print("[+] chinese long filename passed: \(name)")
        }
    }
}
