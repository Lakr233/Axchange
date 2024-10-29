//
//  DeviceFileView+Progress.swift
//  Axchange
//
//  Created by 秋星桥 on 2024/11/11.
//

import SwiftUI

extension DeviceFileView {
    var progressView: some View {
        ZStack {
            VStack {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding()
                ProgressView(value: operationProgress?.fractionCompleted ?? 0)
                    .progressViewStyle(.linear)
                HStack {
                    Text(operationProgressHint ?? "Operation In Progress")
                    Spacer()
                    Text("\(operationProgress?.completedUnitCount ?? 0)/\(operationProgress?.totalUnitCount ?? 1)")
                }
                .font(.system(.footnote, design: .monospaced))
                Button {
                    guard let operationProcessPid else { return }
                    kill(operationProcessPid, 9)
                } label: {
                    Text("Cancel")
                }
                .buttonStyle(.borderedProminent)
                .disabled(operationProcessPid == nil)
                .padding()
            }
            .frame(maxWidth: 300)
            .padding()
        }
    }
}
