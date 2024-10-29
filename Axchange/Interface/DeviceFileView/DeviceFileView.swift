//
//  DeviceFileView.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/27.
//

import QuickLook
import SwiftUI

struct DeviceFileView: View {
    @StateObject var device: Device

    let bannerHeight: CGFloat = 20

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
    @State var operationProcessPid: pid_t? = nil

    @State var dataSource: [RemoteFile] = []
    @State var searchKey: String = ""
    @State var selection: Set<RemoteFile.ID> = []
    @State var sortOrder: [KeyPathComparator<RemoteFile>] = [
        .init(\.name, order: SortOrder.forward),
    ]

    // preview
    @State var quickLookItem: URL? = nil

    let updateQueue = DispatchQueue(label: "wiki.qaq.adb.update")

    var body: some View {
        ZStack {
            switch device.deviceStatus {
            case .unauthorized:
                UnauthorizedView(device: device)
            case .authorized:
                tableViewWithKeyPress
                    .padding(.bottom, bannerHeight)
                    .overlay(controlBar.frame(maxHeight: .infinity, alignment: .bottom))
                    .opacity(operationProgress == nil ? 1 : 0.25)
                    .searchable(text: $searchKey)
                    .onDrop(of: [.fileURL], isTargeted: nil) { dropItems($0) }
                    .disabled(operationProgress != nil)
                    .toolbar { toolbarContents }
            }
            if operationProgress != nil {
                progressView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.thickMaterial)
                    .zIndex(233)
            }
        }
        .quickLookPreview($quickLookItem)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(device.interfaceName)
        .onAppear { updateDataSource() }
        .onChange(of: sourcePath) { _ in updateDataSource() }
    }

    var deviceLogView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 2) {
                ForEach(device.deviceLog) { record in
                    LogElementView(record: record)
                    Divider().tag(record.id)
                }
            }
            .padding()
        }
        .frame(width: 600, height: 250)
    }

    var tableItems: [RemoteFile] {
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
            TableColumn("Type", value: \.type) { element in
                iconForElement(element)
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
                if element.isDirectory || element.isSymbolicLink {
                    Text("N/A")
                        .opacity(0.1)
                } else {
                    Text(formatBytes(value: element.size))
                        .textSelection(.enabled)
                }
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
                    .filledDraggable(item)
            }
        }
        .contextMenu(forSelectionType: RemoteFile.ID.self) { selections in
            selection = selections
            return Group {
                Button("Open") {
                    quickAction(forSelections: selections, behavior: .open)
                }
                tableMenu
            }
        } primaryAction: { selections in
            processPrimaryAction(forSelections: selections)
        }
        .onChange(of: dataSource) { _ in selection = [] }
    }

    @ViewBuilder
    var tableViewWithKeyPress: some View {
        if #available(macOS 14.0, *) {
            tableView
                .onKeyPress(.space) {
                    quickAction(forSelections: selection, behavior: .preview)
                    return .handled
                }
        } else {
            tableView
        }
    }
}

extension TableRow {
    func filledDraggable(_ inputItem: some Transferable) -> some TableRowContent<TableRow<Value>.TableRowValue> {
        if #available(macOS 14.0, *) {
            return self.draggable(inputItem)
        } else {
            return self
        }
    }
}
