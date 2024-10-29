//
//  DeviceFileView+Menu.swift
//  Axchange
//
//  Created by 秋星桥 on 2024/11/11.
//

import SwiftUI

extension DeviceFileView {
    var menu_navBack: some View {
        Button {
            navigateBack()
        } label: {
            Label("Back", systemImage: "arrow.left")
        }
        .keyboardShortcut(.upArrow, modifiers: .command)
        .disabled(sourcePath.pathComponents.count <= 1)
    }

    var menu_refresh: some View {
        Button {
            updateDataSource()
        } label: {
            Label("Refresh", systemImage: "arrow.clockwise")
        }
        .keyboardShortcut("r", modifiers: .command)
    }

    var menu_newFolder: some View {
        Button {
            createFolder()
        } label: {
            Label("New Folder", systemImage: "folder.badge.plus")
        }
        .keyboardShortcut("n", modifiers: .command)
        .disabled(sourcePath.pathComponents.count <= 1)
    }

    var menu_upload: some View {
        Button {
            upload()
        } label: {
            if #available(macOS 14.0, *) {
                Label("Upload", systemImage: "iphone.and.arrow.forward.inward")
            } else {
                Label("Upload", image: "arrow.up")
            }
        }
    }

    var menu_delete: some View {
        Button {
            deleteSelections()
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .keyboardShortcut(.delete)
        .disabled(selection.isEmpty)
    }

    var menu_download: some View {
        Button {
            download()
        } label: {
            Label("Download", systemImage: "arrow.down")
        }
        .disabled(selection.isEmpty)
    }

    @ToolbarContentBuilder
    var toolbarContents: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            menu_navBack
        }
        ToolbarItem { menu_refresh }
        ToolbarItem { menu_newFolder }
        ToolbarItem { menu_upload }
        ToolbarItem { menu_delete }
        ToolbarItem { menu_download }
    }

    @ViewBuilder
    var tableMenu: some View {
        menu_download
        menu_delete
        Divider()
        menu_refresh
        Divider()
        Button("Copy Name") {
            let names = selection
                .compactMap { id in
                    dataSource.first { $0.id == id }
                }
                .map(\.name)
                .joined(separator: "\n")
            NSPasteboard.general.prepareForNewContents()
            NSPasteboard.general.setString(names, forType: .string)
        }
        Button("Copy Path") {
            let names = selection
                .compactMap { id in
                    dataSource.first { $0.id == id }
                }
                .map { $0.dir.appendingPathComponent($0.name).path }
                .joined(separator: "\n")
            NSPasteboard.general.prepareForNewContents()
            NSPasteboard.general.setString(names, forType: .string)
        }
        Divider()
        menu_upload
        menu_newFolder
        Divider()
        menu_navBack
    }
}
