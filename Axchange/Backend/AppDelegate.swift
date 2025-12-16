//
//  AppDelegate.swift
//  Axchange
//
//  Created by 秋星桥 on 2024/11/4.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        try? FileManager.default.removeItem(at: temporaryStorage)
        try? FileManager.default.createDirectory(
            at: temporaryStorage,
            withIntermediateDirectories: true,
            attributes: nil,
        )
    }

    func applicationWillTerminate(_: Notification) {
        print("[*] \(#function)")
        Executor.shared.killallSubprocess()
        try? FileManager.default.removeItem(at: temporaryStorage)
        exit(0)
    }
}
