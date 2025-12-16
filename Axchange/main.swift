//
//  main.swift
//  Axchange
//
//  Created by 秋星桥 on 2024/10/29.
//

import Darwin
import Foundation
import SwiftUI

_ = Executor.shared

let temporaryStorage = URL(fileURLWithPath: NSTemporaryDirectory())
    .appendingPathComponent(Bundle.main.bundleIdentifier!)
    .appendingPathComponent("TemporaryStorage")

struct AxchangeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appModel = AppModel.shared
    @State var openSoftwareLicense = false

    var body: some Scene {
        WindowGroup {
            MainView()
                .sheet(isPresented: $openSoftwareLicense) {
                    LicenseView()
                        .interactiveDismissDisabled()
                }
        }
        .windowResizability(.contentMinSize)
        .commands { commands }
    }

    @CommandsBuilder
    var commands: some Commands {
        SidebarCommands()
        CommandMenu("Device") {
            Button("Search for New Device") {
                Executor.shared.scanForDevices()
            }
            .disabled(appModel.isScanningDevices)
            Divider()
            Button(role: .destructive) {
                Executor.shared.resetADB()
                AppModel.shared.devices = []
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    Executor.shared.scanForDevices()
                }
            } label: {
                HStack {
                    Label("Restart Service", systemImage: "drop.triangle")
                    Spacer()
                }
                .background(Color.accentColor.opacity(0.0001))
            }
            .buttonStyle(PlainButtonStyle())
        }
        CommandMenu("License") {
            Button("View Software License...") {
                openSoftwareLicense = true
            }
        }
    }
}

AxchangeApp.main()
