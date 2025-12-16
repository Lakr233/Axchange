//
//  MainView.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/26.
//

import SwiftUI

enum SidebarSelection: Hashable {
    case welcome
    case guide
    case device(deviceID: String)
}

struct MainView: View {
    @StateObject private var appStatus = AppModel.shared
    @State private var selection: SidebarSelection = .welcome

    @ViewBuilder
    private func detailView(for selection: SidebarSelection) -> some View {
        switch selection {
        case .welcome:
            WelcomeView()
        case .guide:
            GuideView()
        case let .device(deviceID):
            if let device = appStatus.devices.first(where: { $0.id == deviceID }) {
                DeviceFileView(device: device)
            } else {
                WelcomeView()
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection)
                .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
        } detail: {
            NavigationStack {
                detailView(for: selection)
                    .navigationTitle("Axchange")
            }
        }
        .onChange(of: appStatus.devices.map(\.id)) { deviceIDs in
            guard case let .device(deviceID) = selection else {
                return
            }
            guard !deviceIDs.contains(deviceID) else {
                return
            }

            selection = deviceIDs.isEmpty ? .guide : .welcome
        }
    }
}
