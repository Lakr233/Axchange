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

    func deleteFiles(names: [String]) {
        device.deleteFiles(atPaths: names.map { sourcePath.appendingPathComponent($0) })
        updateDataSource()
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

    func downloadSelection(toUrl: URL) {
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
            }
        }
    }
}
