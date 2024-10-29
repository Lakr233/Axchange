//
//  WelcomeView.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/26.
//

import ColorfulX
import SwiftUI

struct WelcomeView: View {
    var version: String {
        var ret = String(
            format: NSLocalizedString("Version: %@ Build: %@ ADB: %@", comment: ""),
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0",
            Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0",
            Executor.version
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

            VStack {
                Spacer()
                Text(version)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .opacity(0.5)
            }
        }
        .padding()
        .navigationTitle("Axchange")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ColorfulView(color: Colorful())
                .opacity(0.25)
                .ignoresSafeArea()
        )
        .usePreferredContentSize()
    }
}
