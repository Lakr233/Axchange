//
//  DeviceFileView+ControlBar.swift
//  Axchange
//
//  Created by 秋星桥 on 2024/11/11.
//

import SwiftUI

extension DeviceFileView {
    var controlBar: some View {
        HStack(spacing: 6) {
            Button {
                showLogs = true
            } label: {
                if isLoading {
                    ProgressView().scaleEffect(0.4)
                } else {
                    if device.deviceLog.last?.recipt.exitCode ?? 0 == 0 {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    } else {
                        Image(systemName: "checkmark.circle.trianglebadge.exclamationmark")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(.red)
                    }
                }
            }
            .buttonStyle(.plain)
            .frame(width: bannerHeight)
            .popover(isPresented: $showLogs) {
                ScrollViewReader { value in
                    deviceLogView.onAppear {
                        if let last = device.deviceLog.last {
                            value.scrollTo(last.id)
                        }
                    }
                }
            }
            Divider()
            Button {
                editingPath.toggle()
            } label: {
                Image(systemName: "character.cursor.ibeam")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
            }
            .buttonStyle(.plain)
            .frame(width: bannerHeight)
            Divider()
            if editingPath {
                temporaryEditableField(initialValue: sourcePath.path) { newValue in
                    editingPath = false
                    sourcePath = URL(fileURLWithPath: newValue)
                }
                .disableAutocorrection(true)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(0 ..< sourcePath.pathComponents.count, id: \.self) { idx in
                            Image(systemName: "play.fill")
                                .foregroundColor(.gray.opacity(0.5))
                                .font(.system(size: 8, weight: .semibold, design: .rounded))
                            Button {
                                sliceToNthAtSourcePath(idx)
                            } label: {
                                Text(nthComponentAtSourcePath(idx))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                }
            }
            Divider()
            Button {
                NSPasteboard.general.prepareForNewContents()
                NSPasteboard.general.setString(device.adbIdentifier, forType: .string)
                showCopied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showCopied = false
                }
            } label: {
                Text(device.adbIdentifier)
                    .opacity(showCopied ? 0 : 1)
            }
            .buttonStyle(.plain)
            .frame(minWidth: 80)
            .overlay(Group {
                if showCopied { Text("Copied").frame(maxWidth: .infinity) }
            })
            .disabled(showCopied)
        }
        .padding(.horizontal, 6)
        .frame(height: bannerHeight)
        .frame(maxWidth: .infinity)
        .background(Color.accentColor.opacity(0.1))
    }
}
