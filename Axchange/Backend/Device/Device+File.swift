//
//  Device+File.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/27.
//

import AuxiliaryExecute
import Foundation

private let jsonDecoder = JSONDecoder()
private let maxThread = max(8, ProcessInfo().processorCount)

extension Device {
    func listDir(atPath path: String) -> [RemoteFile] {
        assert(!Thread.isMainThread)

        let dirCandidates = RemotePath.candidates(for: path)
        var fileNames = [String]()
        for candidate in dirCandidates {
            let receipt = executeADB(withParameters: ["shell", "ls", "\"\(candidate)\""], timeout: 3)
            guard receipt.exitCode == 0 else { continue }
            fileNames = receipt.stdout
                .components(separatedBy: "\n")
                .filter { !$0.isEmpty }
            if !fileNames.isEmpty || receipt.stderr.isEmpty {
                break
            }
        }

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
                guard let file = self.statRemoteFile(inDir: path, name: name) else {
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

    private func statRemoteFile(inDir dir: String, name: String) -> RemoteFile? {
        let fullPath = RemotePath.join(dir: dir, component: name)
        for candidate in RemotePath.candidates(for: fullPath) {
            let output = executeADB(
                withParameters: ["shell", "stat", "-c", Self.statFormat, "\"\(candidate)\""],
                timeout: 3,
            )
            .stdout
            .trimmingCharacters(in: .whitespacesAndNewlines)

            guard let data = output.data(using: .utf8),
                  let coder = try? jsonDecoder.decode(RemoteFile.Stat.self, from: data)
            else {
                continue
            }

            // `stat %n` returns the full path; keep dir/name split so callers can
            // compare against just the file/folder name.
            // Also prefer the stat-reported path for directory derivation to
            // preserve device-side Unicode normalization.
            let actualDir = RemotePath.deletingLastComponent(coder.name)
            let actualName = RemotePath.lastComponent(coder.name)
            return RemoteFile(
                stat: coder,
                dir: actualDir,
                name: actualName,
                deviceIdentifier: adbIdentifier,
            )
        }

        debugPrint("[?] \(#function) \(fullPath)")
        return nil
    }

    func moveFile(atPath: String, toPath: String) {
        guard !atPath.contains("\""),
              !toPath.contains("\"")
        else {
            return
        }
        let fromCandidates = RemotePath.candidates(for: atPath)
        let toCandidates = RemotePath.candidates(for: toPath)
        for from in fromCandidates {
            for to in toCandidates {
                let receipt = executeADB(withParameters: ["shell", "mv", "\"\(from)\"", "\"\(to)\""], timeout: 3)
                if receipt.exitCode == 0 { return }
            }
        }
    }

    func createFolder(atPath: String) {
        guard !atPath.contains("\"") else { return }
        for candidate in RemotePath.candidates(for: atPath) {
            let receipt = executeADB(withParameters: ["shell", "mkdir", "\"\(candidate)\""], timeout: 3)
            if receipt.exitCode == 0 { return }
        }
    }

    func deleteFiles(atPaths: [String]) {
        let group = DispatchGroup()
        let sem = DispatchSemaphore(value: maxThread)
        for path in atPaths {
            guard !path.contains("\"") else { continue }
            group.enter()
            sem.wait()
            DispatchQueue.global().async {
                defer {
                    group.leave()
                    sem.signal()
                }
                for candidate in RemotePath.candidates(for: path) {
                    let receipt = self.executeADB(withParameters: ["shell", "rm", "-rf", "\"\(candidate)\""], timeout: 3)
                    if receipt.exitCode == 0 { break }
                }
            }
        }
        group.wait()
    }

    @discardableResult
    func pushFiles(
        atPaths: [URL],
        toDir: String,
        setPid: ((pid_t) -> Void)? = nil,
        progress: @escaping (URL, Progress) -> Void,
    ) -> Error? {
        guard !toDir.contains("\"") else { return NSError(domain: "adb", code: 9, userInfo: nil) }
        let destCandidates = RemotePath.candidates(for: toDir).map { "\($0)/" }
        for (idx, path) in atPaths.enumerated() {
            guard !path.path.contains("\"") else { continue }
            let value = Progress(totalUnitCount: Int64(atPaths.count))
            value.completedUnitCount = Int64(idx + 1)
            progress(path, value)
            var lastRet: AuxiliaryExecute.ExecuteReceipt?
            for dest in destCandidates {
                let ret = executeADB(withParameters: ["push", path.path, dest], setPid: setPid)
                lastRet = ret
                // killed by ourselves
                guard ret.exitCode != 9 else { return NSError(domain: "adb", code: 9, userInfo: nil) }
                if ret.exitCode == 0 { break }
            }
            if let lastRet, lastRet.exitCode != 0 {
                return NSError(domain: "adb", code: Int(lastRet.exitCode), userInfo: nil)
            }
        }
        return nil
    }

    @discardableResult
    func downloadFiles(
        atPaths: [String],
        toDest: URL,
        setPid: ((pid_t) -> Void)? = nil,
        progress: @escaping (String, Progress) -> Void,
    ) -> Error? {
        for (idx, path) in atPaths.enumerated() {
            // should not exist on android devices so should be good
            guard !path.contains("\"") else { continue }
            let value = Progress(totalUnitCount: Int64(atPaths.count))
            value.completedUnitCount = Int64(idx + 1)
            progress(path, value)
            var lastRet: AuxiliaryExecute.ExecuteReceipt?
            for candidate in RemotePath.candidates(for: path) {
                let ret = executeADB(withParameters: ["pull", candidate, "\(toDest.path)/"], setPid: setPid)
                lastRet = ret
                // killed by ourselves
                guard ret.exitCode != 9 else { return NSError(domain: "adb", code: 9, userInfo: nil) }
                if ret.exitCode == 0 { break }
            }
            if let lastRet, lastRet.exitCode != 0 {
                return NSError(domain: "adb", code: Int(lastRet.exitCode), userInfo: nil)
            }
        }
        return nil
    }
}

extension RemoteFile {
    var isDirectory: Bool { type == "directory" }
    var isSymbolicLink: Bool { type == "symbolic link" }
}
