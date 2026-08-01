//
//  GuideView.swift
//  Axchange
//
//  Created by 秋星桥 on 2024/12/3.
//

import SwiftUI

struct GuideView: View {
    @StateObject var appStatus = AppModel.shared

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "cable.connector.horizontal")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.accentColor)
                .padding(.bottom, 4)

            Text("No Device Connected")
                .font(.system(.headline, design: .rounded))

            Text("Enable ADB on your device, connect it with a cable, then scan.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 320)

            HStack(spacing: 8) {
                Button("Scan") {
                    Executor.shared.scanForDevices()
                }
                .buttonStyle(.borderedProminent)
                .disabled(appStatus.isScanningDevices)

                Button("Documentation") {
                    DocumentationWindowController.show(document: "enable_adb")
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Connect to Axchange")
    }
}
