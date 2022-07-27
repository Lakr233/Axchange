//
//  WelcomeView.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/26.
//

import Colorful
import SwiftUI

struct WelcomeView: View {
    var version: String {
        var ret = "Version: " +
            (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
            + " Build: " +
            (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
            + " "
            + Executor.version
        #if DEBUG
            ret = "👾 \(ret) 👾"
        #endif
        return ret
    }

    var body: some View {
        ZStack {
            ColorfulView(colors: [.accentColor], colorCount: 4)
                .ignoresSafeArea()
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
        .usePreferredContentSize()
    }
}
