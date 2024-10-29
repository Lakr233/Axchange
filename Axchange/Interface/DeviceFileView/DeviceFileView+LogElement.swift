//
//  DeviceFileView+LogElement.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/28.
//

import SwiftUI

extension DeviceFileView {
    struct LogElement: View {
        let record: Device.DeviceExecLog

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    Button {
                        NSPasteboard.general.prepareForNewContents()
                        NSPasteboard.general.setString(record.command, forType: .string)
                    } label: {
                        Text(record.command)
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                }
                if !record.recipt.stdout.isEmpty {
                    Button {
                        NSPasteboard.general.prepareForNewContents()
                        NSPasteboard.general.setString(record.recipt.stdout, forType: .string)
                    } label: {
                        Text(record.recipt.stdout.trimmingCharacters(in: .whitespacesAndNewlines))
                            .lineLimit(5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
                if !record.recipt.stderr.isEmpty {
                    Button {
                        NSPasteboard.general.prepareForNewContents()
                        NSPasteboard.general.setString(record.recipt.stderr, forType: .string)
                    } label: {
                        Text(record.recipt.stderr.trimmingCharacters(in: .whitespacesAndNewlines))
                            .lineLimit(5)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(.footnote, design: .monospaced))
        }
    }
}
