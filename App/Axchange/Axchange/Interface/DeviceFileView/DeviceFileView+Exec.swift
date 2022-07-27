//
//  DeviceFileView+Exec.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/28.
//

import AppKit
import SwiftUI

extension DeviceFileView {
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
        msg.addButton(withTitle: "Confirm")
        msg.addButton(withTitle: "Cancel")
        msg.messageText = "Create New Foler"

        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = "New Foler"
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

    func deleteFiles(names: [String]) {
        device.deleteFiles(atPaths: names.map { sourcePath.appendingPathComponent($0) })
        updateDataSource()
    }

    func uploadFiles(atUrl: [URL]) {
        DispatchQueue.global().async {
            DispatchQueue.withMainAndWait {
                operationProgress = Progress()
                operationProgressHint = "Preparing Upload"
            }
            device.pushFiles(atPaths: atUrl, toDir: sourcePath) { url, progress in
                DispatchQueue.main.async {
                    operationProgress = progress
                    operationProgressHint = "Sending \(url.path)"
                }
            }
            DispatchQueue.withMainAndWait {
                operationProgress = nil
                operationProgressHint = nil
                updateDataSource()
            }
        }
    }

    func downloadSelection(toUrl: URL) {
        DispatchQueue.global().async {
            let paths = selection
                .map(\.name)
                .map { sourcePath.appendingPathComponent($0) }
            DispatchQueue.withMainAndWait {
                operationProgress = Progress()
                operationProgressHint = "Preparing Download"
            }
            device.downloadFiles(atPaths: paths, toDest: toUrl) { url, progress in
                DispatchQueue.withMainAndWait {
                    operationProgress = progress
                    operationProgressHint = "Downloading \(url.path)"
                }
            }
            DispatchQueue.withMainAndWait {
                operationProgress = nil
                operationProgressHint = nil
            }
        }
    }
}
