//
//  DeviceFileView+Helper.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/28.
//

import SwiftUI

private let bytesFormatter = ByteCountFormatter()

extension DeviceFileView {
    func temporaryEditableField(initialValue: String, onSubmit: @escaping (String) -> Void) -> some View {
        var str: String = initialValue
        let binding = Binding<String>.init {
            str
        } set: { newValue in
            str = newValue
        }
        return TextField("", text: binding)
            .onSubmit { onSubmit(str) }
    }

    func nthComponentAtSourcePath(_ idx: Int) -> String {
        let comps = sourcePath.pathComponents
        guard idx >= 0, idx < comps.count else {
            return "?"
        }
        return comps[idx]
    }

    func sliceToNthAtSourcePath(_ idx: Int) {
        var comps = sourcePath.pathComponents
        guard comps.count > idx + 1 else { return }
        guard comps.count > 0 else {
            sourcePath = URL(fileURLWithPath: "/")
            return
        }
        let left = idx + 1
        while comps.count > left {
            comps.removeLast()
        }
        let subPath = comps
            .dropFirst()
            .joined(separator: "/")
        sourcePath = URL(fileURLWithPath: "/" + subPath)
    }

    func formatBytes(value: UInt64) -> String {
        bytesFormatter.string(fromByteCount: Int64(exactly: value) ?? 0)
    }
}
