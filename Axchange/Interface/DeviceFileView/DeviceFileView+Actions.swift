//
//  DeviceFileView+Actions.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/28.
//

import AppKit
import SwiftUI

extension DeviceFileView {
    func navigateBack() {
        sourcePath.deleteLastPathComponent()
        searchKey = ""
    }

    func updateDataSource() {
        let path = sourcePath
        UserDefaults.standard.set(path.path, forKey: device.adbIdentifier)
        updateQueue.async {
            DispatchQueue.withMainAndWait {
                self.isLoading = true
                self.dataSource = []
            }
            defer {
                DispatchQueue.withMainAndWait {
                    self.isLoading = false
                }
            }
            device.requestUpdateDeviceAuthorizeStatus()
            let list = device.listDir(withUrl: path)
            DispatchQueue.withMainAndWait {
                dataSource = list
            }
        }
    }

    func renameItem(withName: String, newName: String) {
        let origPath = sourcePath.appendingPathComponent(withName)
        let newPath = sourcePath.appendingPathComponent(newName)
        device.moveFile(atPath: origPath, toPath: newPath)
        updateDataSource()
    }

    func createFolder() {
        let msg = NSAlert()
        msg.addButton(withTitle: NSLocalizedString("Create", comment: ""))
        msg.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        msg.messageText = String(
            format: NSLocalizedString("Create New Folder in %@", comment: ""),
            sourcePath.lastPathComponent
        )

        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = NSLocalizedString("New Folder", comment: "")
        msg.window.initialFirstResponder = txt
        msg.accessoryView = txt

        guard let window = NSApp.keyWindow else {
            return
        }
        msg.beginSheetModal(for: window) { resp in
            let text = txt.stringValue
            guard resp == .alertFirstButtonReturn,
                  !text.isEmpty,
                  !text.contains("\"")
            else {
                return
            }
            device.createFolder(atPath: sourcePath.appendingPathComponent(text))
            updateDataSource()
        }
    }

    func deleteSelections() {
        let msg = NSAlert()
        msg.addButton(withTitle: NSLocalizedString("Confirm", comment: ""))
        msg.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        msg.messageText = String(
            format: NSLocalizedString("Are you sure you want to delete %d files?", comment: ""),
            selection.count
        )

        guard let window = NSApp.keyWindow else {
            return
        }
        msg.beginSheetModal(for: window) { resp in
            guard resp == .alertFirstButtonReturn else { return }
            deleteFiles(names: selection.map(\.name))
        }
    }

    func deleteFiles(names: [String]) {
        device.deleteFiles(atPaths: names.map { sourcePath.appendingPathComponent($0) })
        updateDataSource()
    }

    func upload() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.resolvesAliases = true
        panel.message = String(
            format: NSLocalizedString("Select files to upload to %@", comment: ""),
            sourcePath.lastPathComponent
        )
        guard let window = NSApp.keyWindow else {
            return
        }
        panel.beginSheetModal(for: window) { resp in
            guard resp == .OK else { return }
            uploadFiles(atUrl: panel.urls)
        }
    }

    func uploadFiles(atUrl: [URL]) {
        DispatchQueue.global().async {
            DispatchQueue.withMainAndWait {
                operationProgress = Progress()
                operationProgressHint = NSLocalizedString("Preparing Upload", comment: "")
            }
            device.pushFiles(atPaths: atUrl, toDir: sourcePath, setPid: { pid in
                DispatchQueue.withMainAndWait {
                    self.operationProcessPid = pid
                }
            }) { url, progress in
                DispatchQueue.main.async {
                    operationProgress = progress
                    operationProgressHint = String(
                        format: NSLocalizedString("Uploading %@", comment: ""),
                        url.lastPathComponent
                    )
                }
            }
            DispatchQueue.withMainAndWait {
                operationProgress = nil
                operationProgressHint = nil
                operationProcessPid = nil
                updateDataSource()
            }
        }
    }

    func download() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.resolvesAliases = true
        guard let window = NSApp.keyWindow else {
            return
        }
        panel.beginSheetModal(for: window) { resp in
            guard resp == .OK,
                  let url = panel.url
            else {
                return
            }
            downloadSelection(toUrl: url)
        }
    }

    func downloadSelection(toUrl: URL, onNonePromisedCompletionSuccess: (() -> Void)? = nil) {
        DispatchQueue.global().async {
            let paths = selection
                .map(\.name)
                .map { sourcePath.appendingPathComponent($0) }
            DispatchQueue.withMainAndWait {
                operationProgress = Progress()
                operationProgressHint = NSLocalizedString("Preparing Download", comment: "")
            }
            device.downloadFiles(atPaths: paths, toDest: toUrl, setPid: { pid in
                DispatchQueue.withMainAndWait {
                    self.operationProcessPid = pid
                }
            }) { url, progress in
                DispatchQueue.withMainAndWait {
                    operationProgress = progress
                    operationProgressHint = String(
                        format: NSLocalizedString("Downloading %@", comment: ""),
                        url.lastPathComponent
                    )
                }
            }
            DispatchQueue.withMainAndWait {
                operationProgress = nil
                operationProgressHint = nil
                operationProcessPid = nil
                onNonePromisedCompletionSuccess?()
            }
        }
    }

    func processPrimaryAction(forSelection selection: RemoteFile.ID) {
        self.selection = [selection]
        processPrimaryAction(forSelections: [selection])
    }

    func processPrimaryAction(forSelections selections: Set<RemoteFile.ID>) {
        print("[i] processing actions for \(selections.count) items")
        selection = selections
        let items = selections.compactMap { id in
            dataSource.first { $0.id == id }
        }
        if items.count == 0 {
            return
        } else if items.count == 1 {
            let item = items[0]
            if item.isDirectory || item.isSymbolicLink {
                pushIntoDirectory(byAppendingPath: item.name)
            } else {
                quickAction(forSelection: item.id, behavior: .open)
            }
        } else { // items.count > 1
            quickAction(forSelections: selections, behavior: .open)
        }
    }

    func pushIntoDirectory(byAppendingPath name: String) {
        sourcePath.appendPathComponent(name)
    }

    enum QuickAction: String, Equatable, Codable {
        case preview
        case open
    }

    func quickAction(forSelection selection: RemoteFile.ID, behavior: QuickAction) {
        self.selection = [selection]
        quickAction(forSelections: [selection], behavior: behavior)
    }

    func quickAction(forSelections selections: Set<RemoteFile.ID>, behavior: QuickAction) {
        if selections.isEmpty { return }

        print("[*] quick \(behavior.rawValue) requested for \(selections.count) items")
        let items = selections.compactMap { id in
            dataSource.first { $0.id == id }
        }

        let tempDir = temporaryStorage
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.removeItem(at: tempDir)
        try? FileManager.default.createDirectory(
            at: tempDir,
            withIntermediateDirectories: true,
            attributes: nil
        )
        selection = selections
        downloadSelection(toUrl: tempDir) {
            // verify the download
            var error: String?
            for item in items {
                let url = tempDir.appendingPathComponent(item.name)
                if !FileManager.default.fileExists(atPath: url.path) {
                    error = String(
                        format: NSLocalizedString("Failed to download item %@", comment: ""),
                        item.name
                    )
                    break
                }
            }
            if let error {
                let msg = NSAlert()
                msg.addButton(withTitle: NSLocalizedString("OK", comment: ""))
                msg.messageText = error
                guard let window = NSApp.keyWindow else {
                    return
                }
                msg.beginSheetModal(for: window, completionHandler: nil)
                return
            }

            // all downloaded
            switch behavior {
            case .preview:
                if items.count == 1 {
                    quickLookItem = tempDir.appendingPathComponent(items[0].name)
                } else {
                    NSWorkspace.shared.activateFileViewerSelecting([tempDir])
                }
            case .open:
                if items.count <= 10 {
                    for item in items {
                        let url = tempDir.appendingPathComponent(item.name)
                        NSWorkspace.shared.open(url)
                    }
                } else {
                    NSWorkspace.shared.activateFileViewerSelecting([tempDir])
                }
            }
        }
    }

    func dropItems(_ providers: [NSItemProvider]) -> Bool {
        let urls = providers.compactMap { provider -> URL? in
            var url: URL?
            let sem = DispatchSemaphore(value: 0)
            _ = provider.loadObject(ofClass: URL.self) { item, _ in
                url = item
                sem.signal()
            }
            sem.wait()
            return url
        }
        DispatchQueue.global().async {
            uploadFiles(atUrl: urls)
        }
        return true
    }
}
