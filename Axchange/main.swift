//
//  main.swift
//  Axchange
//
//  Created by 秋星桥 on 2024/10/29.
//

import Foundation
import SwiftUI

_ = Executor.shared

struct AxchangeApp: App {
    static let appBundleIdentifier: String = Bundle
        .main
        .bundleIdentifier ?? "wiki.qaq.unknown"

    static let appVersion: String =
        Bundle
            .main
            .infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "unknown"

    let documentDirectory: URL = {
        let availableDirectories = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)

        let dir = availableDirectories[0].appendingPathComponent(Bundle.main.bundleIdentifier!)
        try? FileManager.default.createDirectory(
            at: dir,
            withIntermediateDirectories: true,
            attributes: nil
        )
        return dir
    }()

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .windowToolbarStyle(.unifiedCompact)
        .commands { SidebarCommands() }
    }
}

AxchangeApp.main()
