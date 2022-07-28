//
//  DeviceView.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/27.
//

import SwiftUI

private let bannerHeight: CGFloat = 20

struct DeviceFileView: View {
    @StateObject var device: Device

    init(device: Device) {
        _device = StateObject(wrappedValue: device)

        let initialUrl = URL(
            fileURLWithPath: UserDefaults
                .standard
                .string(forKey: device.adbIdentifier)
                ?? "/"
        )
        _sourcePath = State<URL>(initialValue: initialUrl)
    }

    @State var sourcePath: URL

    // banner
    @State var editingPath: Bool = false
    @State var showCopied: Bool = false
    @State var showLogs: Bool = false

    // major
    @State var isLoading: Bool = true
    @State var operationProgress: Progress? = nil
    @State var operationProgressHint: String? = nil
    @State var dataSource: [Device.RemoteFile] = []
    @State var searchKey: String = ""
    @State var selection: Set<Device.RemoteFile.ID> = []
    @State var sortOrder: [KeyPathComparator<Device.RemoteFile>] = [
        .init(\.name, order: SortOrder.forward),
    ]

    let updateQueue = DispatchQueue(label: "wiki.qaq.adb.update")

    var body: some View {
        Group {
            if device.deviceStatus == .authorized {
                if operationProgress != nil {
                    progressView
                } else {
                    tableContent
                }
            } else {
                UnauthorizedView(device: device)
            }
        }
        .navigationTitle(device.interfaceName)
        .onAppear { updateDataSource() }
        .onChange(of: sourcePath) { _ in updateDataSource() }
    }

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
            }
            .frame(maxWidth: 300)
            .padding()
        }
    }

    var tableContent: some View {
        tableView
            .searchable(text: $searchKey)
            .toolbar {
                ToolbarItem {
                    Button {
                        sourcePath.deleteLastPathComponent()
                    } label: {
                        Label("Back", systemImage: "arrow.left")
                    }
                    .disabled(sourcePath.pathComponents.count <= 1)
                }
                ToolbarItem {
                    Button {
                        updateDataSource()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
                ToolbarItem {
                    Button {
                        createFolder()
                    } label: {
                        Label("New Folder", systemImage: "folder.badge.plus")
                    }
                    .disabled(sourcePath.pathComponents.count <= 1)
                }
                ToolbarItem {
                    Button {
                        let msg = NSAlert()
                        msg.addButton(withTitle: "Confirm")
                        msg.addButton(withTitle: "Cancel")
                        msg.messageText = "Are you sure you want to delete \(selection.count) files?"

                        guard let window = NSApp.keyWindow else {
                            return
                        }
                        msg.beginSheetModal(for: window) { resp in
                            guard resp == .alertFirstButtonReturn else { return }
                            deleteFiles(names: selection.map(\.name))
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .disabled(selection.isEmpty)
                }
                ToolbarItem {
                    Button {
                        let panel = NSOpenPanel()
                        panel.canChooseFiles = true
                        panel.allowsMultipleSelection = true
                        panel.canChooseDirectories = true
                        panel.resolvesAliases = true
                        guard let window = NSApp.keyWindow else {
                            return
                        }
                        panel.beginSheetModal(for: window) { resp in
                            guard resp == .OK else { return }
                            uploadFiles(atUrl: panel.urls)
                        }
                    } label: {
                        Label("Upload", systemImage: "arrow.up")
                    }
                }
                ToolbarItem {
                    Button {
                        let panel = NSOpenPanel()
                        panel.allowsMultipleSelection = false
                        panel.canChooseFiles = false
                        panel.canChooseDirectories = true
                        panel.resolvesAliases = true
                        guard let window = NSApp.keyWindow else {
                            return
                        }
                        panel.beginSheetModal(for: window) { resp in
                            guard resp == .OK,
                                  let url = panel.url
                            else {
                                return
                            }
                            downloadSelection(toUrl: url)
                        }
                    } label: {
                        Label("Download", systemImage: "arrow.down")
                    }
                    .disabled(selection.isEmpty)
                }
            }
            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                let urls = providers.compactMap { provider -> URL? in
                    var url: URL?
                    let sem = DispatchSemaphore(value: 0)
                    _ = provider.loadObject(ofClass: URL.self) { item, _ in
                        url = item
                        sem.signal()
                    }
                    sem.wait()
                    return url
                }
                DispatchQueue.global().async {
                    uploadFiles(atUrl: urls)
                }
                return true
            }
            .padding(.bottom, bannerHeight)
            .overlay(controlBanner.frame(maxHeight: .infinity, alignment: .bottom))
    }

    var controlBanner: some View {
        HStack(spacing: 6) {
            Button {
                showLogs = true
            } label: {
                if isLoading {
                    ProgressView().scaleEffect(0.4)
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                }
            }
            .buttonStyle(.plain)
            .frame(width: bannerHeight)
            .popover(isPresented: $showLogs) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(device.deviceLog) { record in
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
                                            .frame(maxWidth: .infinity, maxHeight: 100, alignment: .leading)
                                    }
                                    .buttonStyle(.plain)
                                }
                                if !record.recipt.stderr.isEmpty {
                                    Button {
                                        NSPasteboard.general.prepareForNewContents()
                                        NSPasteboard.general.setString(record.recipt.stderr, forType: .string)
                                    } label: {
                                        Text(record.recipt.stderr.trimmingCharacters(in: .whitespacesAndNewlines))
                                            .foregroundColor(.red)
                                            .frame(maxWidth: .infinity, maxHeight: 100, alignment: .leading)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(.footnote, design: .monospaced))
                            Divider()
                        }
                    }
                    .padding()
                }
                .frame(width: 600, height: 250)
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

    var tableItems: [Device.RemoteFile] {
        if searchKey.isEmpty {
            return dataSource.sorted(using: sortOrder)
        }
        let key = searchKey.lowercased()
        return dataSource
            .filter { $0.name.lowercased().contains(key) }
            .sorted(using: sortOrder)
    }

    var tableView: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("🏳️‍🌈", value: \.type) { element in
                Group {
                    if element.type == "directory" {
                        Image(systemName: "folder")
                            .onTapGesture { sourcePath.appendPathComponent(element.name) }
                    } else if element.type == "symbolic link" {
                        Image(systemName: "link")
                            .onTapGesture { sourcePath.appendPathComponent(element.name) }
                    } else {
                        Image(systemName: "doc")
                    }
                }
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity)
            }
            .width(19)
            TableColumn("Name", value: \.name) { element in
                temporaryEditableField(initialValue: element.name) { newName in
                    renameItem(withName: element.name, newName: newName)
                }
            }
            .width(min: 50, ideal: 150, max: .infinity)
            TableColumn("Permission", value: \.permissions) { element in
                Text(element.permissions)
                    .textSelection(.enabled)
                    .font(.system(.body, design: .monospaced))
            }
            .width(85)
            TableColumn("Size", value: \.size) { element in
                Text(formatBytes(value: element.size))
                    .textSelection(.enabled)
            }
            .width(min: 50, ideal: 60, max: .infinity)
            TableColumn("Create Date", value: \.birthday) { element in
                Text(element.birthday.formatted())
                    .textSelection(.enabled)
            }
            .width(min: 50, ideal: 120, max: .infinity)
            TableColumn("Last Modified", value: \.modified) { element in
                Text(element.modified.formatted())
                    .textSelection(.enabled)
            }
            .width(min: 50, ideal: 120, max: .infinity)
        } rows: {
            ForEach(tableItems) { item in
                TableRow(item)
            }
        }
        .onChange(of: dataSource) { _ in selection = [] }
    }
}
