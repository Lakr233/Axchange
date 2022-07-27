//
//  AxchangeApp.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/26.
//

import SwiftUI

@main
struct AxchangeApp: App {
    public let documentDirectory: URL = {
        let availableDirectories = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)

        #if DEBUG
            return availableDirectories[0]
                .appendingPathComponent("PasteboardAction")
        #else
            return availableDirectories[0]
                .appendingPathComponent("PasteboardAction.Debug")
        #endif
    }()

    init() {
        applicationSetup()
    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .windowToolbarStyle(.unifiedCompact)
        .commands { SidebarCommands() }
    }
}
