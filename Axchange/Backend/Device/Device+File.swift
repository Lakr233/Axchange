//
//  Device+File.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/27.
//

import Foundation

private let jsonDecoder = JSONDecoder()
private let maxThread = max(8, ProcessInfo().processorCount)

extension Device {
    func listDir(withUrl url: URL) -> [RemoteFile] {
        assert(!Thread.isMainThread)
        let fileNames = executeADB(withParameters: ["shell", "ls", "\"\(url.path)\""], timeout: 3)
            .stdout
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
        var result = [RemoteFile]()
        let sem = DispatchSemaphore(value: maxThread)
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
              let coder = try? jsonDecoder.decode(RemoteFile.Stat.self, from: data)
        else {
            debugPrint("[?] \(#function) \(url.path)")
            return nil
        }

        return RemoteFile(
            stat: coder,
            dir: url.deletingLastPathComponent(),
            name: url.lastPathComponent,
            deviceIdentifier: adbIdentifier
        )
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
        let sem = DispatchSemaphore(value: maxThread)
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

    @discardableResult
    func pushFiles(
        atPaths: [URL],
        toDir: URL,
        setPid: ((pid_t) -> Void)? = nil,
        progress: @escaping (URL, Progress) -> Void
    ) -> Error? {
        guard !toDir.path.contains("\"") else { return NSError(domain: "adb", code: 9, userInfo: nil) }
        for (idx, path) in atPaths.enumerated() {
            guard !path.path.contains("\"") else { continue }
            let value = Progress(totalUnitCount: Int64(atPaths.count))
            value.completedUnitCount = Int64(idx + 1)
            progress(path, value)
            let ret = executeADB(withParameters: ["push", path.path, "\(toDir.path)/"], setPid: setPid)
            // killed by ourselves
            guard ret.exitCode != 9 else { return NSError(domain: "adb", code: 9, userInfo: nil) }
        }
        return nil
    }

    @discardableResult
    func downloadFiles(
        atPaths: [URL],
        toDest: URL,
        setPid: ((pid_t) -> Void)? = nil,
        progress: @escaping (URL, Progress) -> Void
    ) -> Error? {
        for (idx, path) in atPaths.enumerated() {
            // should not exist on android devices so should be good
            guard !path.path.contains("\"") else { continue }
            let value = Progress(totalUnitCount: Int64(atPaths.count))
            value.completedUnitCount = Int64(idx + 1)
            progress(path, value)
            let ret = executeADB(withParameters: ["pull", path.path, "\(toDest.path)/"], setPid: setPid)
            // killed by ourselves
            guard ret.exitCode != 9 else { return NSError(domain: "adb", code: 9, userInfo: nil) }
        }
        return nil
    }
}

extension RemoteFile {
    var isDirectory: Bool { type == "directory" }
    var isSymbolicLink: Bool { type == "symbolic link" }
}
