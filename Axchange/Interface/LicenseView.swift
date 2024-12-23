//
//  LicenseView.swift
//  Axchange
//
//  Created by 秋星桥 on 2024/10/30.
//

import SwiftUI

private let licenseText = try! String(
    contentsOf: Bundle.main.url(forResource: "LICENSE", withExtension: "txt")!
)

struct LicenseView: View {
    @State var loading = false
    @State var text: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Software License")
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Divider().padding(.horizontal, -16)
            if loading || text.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        DispatchQueue.global().async {
                            _ = licenseText
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                load()
                            }
                        }
                    }
            } else {
                TextEditor(text: .constant(text))
                    .font(.system(.footnote, design: .monospaced))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            Divider().padding(.horizontal, -16)
            HStack {
                Button("Learn more about how ADB works") {
                    NSWorkspace.shared.open(URL(string: "https://developer.android.com/tools/adb")!)
                }
                Button("Feedback") {
                    NSWorkspace.shared.open(URL(string: "https://github.com/Lakr233/Axchange/issues")!)
                }
                Spacer()
                Button("Accept") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(16)
        .frame(width: 600, height: 400)
    }

    func load() {
        loading = false
        text = licenseText
    }
}
