//
//  RemoteFile.swift
//  Axchange
//
//  Created by 秋星桥 on 2024/11/15.
//

import CoreTransferable
import UniformTypeIdentifiers

struct RemoteFile: Codable, Equatable, Hashable, Identifiable {
    var id: Self { self }

    let dir: URL
    let name: String

    let permissions: String
    let type: String
    let size: UInt64
    let birthday: Date
    let modified: Date

    let deviceIdentifier: String

    init?(stat: Stat, dir: URL, name: String, deviceIdentifier: String) {
        _ = stat
        self.dir = dir
        self.name = name
        permissions = stat.access
        type = stat.type
        guard let size = UInt64(stat.size),
              let birthTimestamp = Double(stat.birthday),
              let modifiedTimestamp = Double(stat.modified_date)
        else {
            return nil
        }
        self.size = size
        birthday = Date(timeIntervalSince1970: birthTimestamp)
        modified = Date(timeIntervalSince1970: modifiedTimestamp)
        self.deviceIdentifier = deviceIdentifier
    }
}

extension RemoteFile {
    struct Stat: Codable, Equatable, Hashable {
        let name: String
        let permissions: String
        let type: String
        let size: String
        let birthday: String
        let modified_date: String
        let access: String
    }
}

extension RemoteFile: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        let exportingBehavior: @Sendable (RemoteFile) async throws -> SentTransferredFile = { input in
            let tempDir = temporaryStorage
                .appendingPathComponent("DragSession")
                .appendingPathComponent(UUID().uuidString)
            let device = AppModel.shared.devices.first { dev in
                dev.adbIdentifier == input.deviceIdentifier
            }
            guard let device else {
                return .init(tempDir) // some thing not exists should be good
            }
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            let path = input.dir.appendingPathComponent(input.name)
            print("[*] pulling \(path) from \(device.adbIdentifier)")
            await withCheckedContinuation { cont in
                device.downloadFiles(atPaths: [path], toDest: tempDir) { _, _ in }
                cont.resume()
            }
            print("[*] pulled \(path) from \(device.adbIdentifier), resuming drag")
            return .init(tempDir.appendingPathComponent(input.name), allowAccessingOriginalFile: true)
        }
        let importingBehavior: @Sendable (ReceivedTransferredFile) async throws -> RemoteFile = { _ in
            fatalError()
        }
        return FileRepresentation(
            contentType: .data,
            shouldAttemptToOpenInPlace: true,
            exporting: exportingBehavior,
            importing: importingBehavior
        )
    }
}
