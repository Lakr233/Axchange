//
//  Device+File.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/27.
//

import Foundation

private let jsonDecoder = JSONDecoder()

extension Device {
    struct RemoteFile: Codable, Equatable, Hashable, Identifiable {
        var id: Self { self }

        let dir: URL
        let name: String

        let permissions: String
        let type: String
        let size: UInt64
        let birthday: Date
        let modified: Date

        fileprivate init?(stat: StatCoder, dir: URL, name: String) {
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
        }
    }

    fileprivate struct StatCoder: Codable, Equatable, Hashable {
        let name: String
        let permissions: String
        let type: String
        let size: String
        let birthday: String
        let modified_date: String
        let access: String
    }

    func listDir(withUrl url: URL) -> [RemoteFile] {
        assert(!Thread.isMainThread)
        let fileNames = executeADB(withParameters: ["shell", "ls", "\"\(url.path)\""], timeout: 3)
            .stdout
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
        var result = [RemoteFile]()
        let sem = DispatchSemaphore(value: 8)
        let group = DispatchGroup()
        let lock = NSLock()
        for name in fileNames {
            DispatchQueue.global().async {
                defer {
                    group.leave()
                    sem.signal()
                }
                let path = url.appendingPathComponent(name)
                guard let file = self.statRemoteFile(viaPath: path) else {
                    return
                }
                lock.lock()
                result.append(file)
                lock.unlock()
            }
            group.enter()
            sem.wait()
        }
        group.wait()
        return result.sorted { $0.name < $1.name }
    }

    private static let statFormat: String = """
    '
    {
        "name": "%n",
        "permissions": "%a",
        "type": "%F",
        "size": "%s",
        "birthday": "%Z",
        "modified_date": "%Y",
        "access": "%A"
    }
    '
    """
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .replacingOccurrences(of: "\n", with: "")
    .replacingOccurrences(of: " ", with: "")

    private func statRemoteFile(viaPath url: URL) -> RemoteFile? {
        let output = executeADB(withParameters: ["shell", "stat", "-c", Self.statFormat, "\"\(url.path)\""], timeout: 3)
            .stdout
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = output.data(using: .utf8),
              let coder = try? jsonDecoder.decode(StatCoder.self, from: data)
        else {
            debugPrint("[?] \(#function) \(url.path)")
            return nil
        }

        return RemoteFile(stat: coder, dir: url.deletingLastPathComponent(), name: url.lastPathComponent)
    }

    func moveFile(atPath: URL, toPath: URL) {
        guard !atPath.path.contains("\""),
              !toPath.path.contains("\"")
        else {
            return
        }
        _ = executeADB(withParameters: ["shell", "mv", "\"\(atPath.path)\"", "\"\(toPath.path)\""], timeout: 3)
    }

    func createFolder(atPath: URL) {
        guard !atPath.path.contains("\"") else { return }
        _ = executeADB(withParameters: ["shell", "mkdir", "\"\(atPath.path)\""], timeout: 3)
    }

    func deleteFiles(atPaths: [URL]) {
        let group = DispatchGroup()
        let sem = DispatchSemaphore(value: 8)
        for path in atPaths {
            guard !path.path.contains("\"") else { continue }
            group.enter()
            sem.wait()
            DispatchQueue.global().async {
                defer {
                    group.leave()
                    sem.signal()
                }
                _ = self.executeADB(withParameters: ["shell", "rm", "-rf", "\"\(path.path)\""], timeout: 3)
            }
        }
        group.wait()
    }

    func pushFiles(atPaths: [URL], toDir: URL, progress: @escaping (URL, Progress) -> Void) {
        guard !toDir.path.contains("\"") else { return }
        for (idx, path) in atPaths.enumerated() {
            guard !path.path.contains("\"") else { continue }
            let value = Progress(totalUnitCount: Int64(atPaths.count))
            value.completedUnitCount = Int64(idx + 1)
            progress(path, value)
            _ = executeADB(withParameters: ["push", path.path, "\(toDir.path)/"])
        }
    }

    func downloadFiles(atPaths: [URL], toDest: URL, progress: @escaping (URL, Progress) -> Void) {
        for (idx, path) in atPaths.enumerated() {
            guard !path.path.contains("\"") else { continue }
            let value = Progress(totalUnitCount: Int64(atPaths.count))
            value.completedUnitCount = Int64(idx + 1)
            progress(path, value)
            _ = executeADB(withParameters: ["pull", path.path, "\(toDest.path)/"])
        }
    }
}
