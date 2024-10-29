//
//  DeviceFileView+RowIcon.swift
//  Axchange
//
//  Created by 秋星桥 on 2024/11/11.
//

import SwiftUI

extension DeviceFileView {
    @ViewBuilder
    func iconForElement(_ element: RemoteFile) -> some View {
        Group {
            if element.isDirectory {
                Text("\(Image(systemName: "folder"))")
            } else if element.isSymbolicLink {
                Text("\(Image(systemName: "link"))")
            } else {
                Image(systemName: "doc")
            }
        }
        .contentShape(Rectangle())
        .onHover { hover in
            if hover {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        .onTapGesture { processPrimaryAction(forSelection: element.id) }
        .foregroundColor(.accentColor)
        .frame(maxWidth: .infinity)
    }
}
