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
        let binding = Binding<String> {
            str
        } set: { newValue in
            str = newValue
        }
        return TextField("", text: binding)
            .onSubmit { onSubmit(str) }
    }

    func nthComponentAtSourcePath(_ idx: Int) -> String {
        let comps = RemotePath.pathComponents(sourcePath)
        guard idx >= 0, idx < comps.count else {
            return "?"
        }
        return comps[idx]
    }

    func sliceToNthAtSourcePath(_ idx: Int) {
        sourcePath = RemotePath.sliceToNthComponent(sourcePath, idx)
    }

    func formatBytes(value: UInt64) -> String {
        bytesFormatter.string(fromByteCount: Int64(exactly: value) ?? 0)
    }
}
