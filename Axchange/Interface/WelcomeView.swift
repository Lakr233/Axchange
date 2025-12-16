//
//  WelcomeView.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/26.
//

import ColorfulX
import SwiftUI

private extension Executor.ADBServiceType {
    var uiText: String {
        switch self {
        case .pending:
            NSLocalizedString("Pending Connection", comment: "")
        case .systemProvided:
            NSLocalizedString("System", comment: "")
        case .applicationProvided:
            NSLocalizedString("Application Bundled", comment: "")
        }
    }
}

struct WelcomeView: View {
    @StateObject var appStatus = AppModel.shared
    @StateObject var executor = Executor.shared

    var version: String {
        var ret = String(
            format: NSLocalizedString("Version: %@ Build: %@ ADB: %@ @ %d @ %@", comment: ""),
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0",
            Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0",
            executor.version,
            executor.adbServerPort,
            executor.serviceType.uiText,
        )
        #if DEBUG
            ret = "👾 \(ret) 👾"
        #endif
        return ret
    }

    struct Colorful: ColorfulColors {
        var colors: [ColorElement] { [
            .init(Color.accentColor),
            .init(Color.accentColor),
            .init(Color.accentColor),
            .init(Color.accentColor),
            .init(Color.clear),
            .init(Color.clear),
            .init(Color.clear),
            .init(Color.clear),
        ] }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 4) {
                Image("Avatar")
                    .antialiased(true)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 128, height: 128)

                Spacer().frame(height: 16)

                Text("Welcome to Axchange")
                    .font(.system(.headline, design: .rounded))

                Spacer().frame(height: 24)
            }

            VStack(spacing: 8) {
                Spacer()
                Text(version)
                    .contentTransition(.numericText())
                    .animation(.spring, value: version)
            }
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .opacity(0.5)
        }
        .padding()
        .navigationTitle("Axchange")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ColorfulView(color: Colorful(), frameLimit: .constant(30))
                .opacity(0.25)
                .ignoresSafeArea(),
        )
        .usePreferredContentSize()
        .removeToolbarBackgroundOnTahoe()
    }
}

private extension View {
    func removeToolbarBackgroundOnTahoe() -> some View {
        if #available(macOS 15.0, *) {
            return toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        } else {
            return self
        }
    }
}
