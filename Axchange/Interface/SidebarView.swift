//
//  SidebarView.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/26.
//

import SwiftUI

struct SidebarView: View {
    @StateObject var appStatus = AppModel.shared
    @Binding var selection: SidebarSelection

    var progressIndicator: some View {
        HStack(spacing: 4) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 18, height: 18)
                .overlay(
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.4),
                )
                .frame(width: 18, height: 18)
            Text("Scanning...")
                .font(.system(.headline, design: .rounded))
                .multilineTextAlignment(.leading)
            Spacer()
        }
    }

    var body: some View {
        List(selection: $selection) {
            Label("Welcome", systemImage: "sun.min.fill")
                .tag(SidebarSelection.welcome)

            Section("Devices") {
                if appStatus.devices.isEmpty {
                    Label("No Device", systemImage: "app.dashed")
                        .tag(SidebarSelection.guide)
                } else {
                    ForEach(appStatus.devices) { device in
                        Label(device.interfaceName, systemImage: "flipphone")
                            .tag(SidebarSelection.device(deviceID: device.id))
                    }
                }
            }
            Section("Misc") {
                Button {
                    Executor.shared.scanForDevices()
                } label: {
                    HStack {
                        Label("Scan", systemImage: "cable.connector.horizontal")
                        Spacer()
                    }
                    .background(Color.accentColor.opacity(0.0001))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .disabled(appStatus.isScanningDevices)
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom, alignment: .leading, spacing: 0) {
            if appStatus.isScanningDevices {
                progressIndicator
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .transition(.opacity)
            }
        }
        .animation(.interactiveSpring(), value: appStatus.isScanningDevices)
    }
}
