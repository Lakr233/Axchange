//
//  Device+Prop.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/27.
//

import Foundation

extension Device {
    func requestPopulateDeviceProperty() {
        adbQueue.async { self.populateDeviceProperty() }
    }

    func requestUpdateDeviceAuthorizeStatus() {
        adbQueue.async { self.updateDeviceAuthorizeStatus() }
    }

    private func updateDeviceAuthorizeStatus() {
        var status = Device.Status.unauthorized
        for device in Executor.shared.listDevices() where device.0 == adbIdentifier {
            status = device.1
            break
        }
        DispatchQueue.withMainAndWait {
            guard self.deviceStatus != status else {
                return
            }
            self.deviceStatus = status
            self.requestPopulateDeviceProperty()
        }
    }

    private func populateDeviceProperty() {
        let deviceProps = executeADB(command: "shell getprop")
        let props = deviceProps.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .compactMap { self.invokeDeviceProp(line: $0) }
            .reduce(into: [String: String]()) { $0[$1.0] = $1.1 }
        populateDeviceName(fromMeta: props)
    }

    private func invokeDeviceProp(line: String) -> (String, String)? {
        let compos = line.split(
            separator: ":",
            maxSplits: 1,
            omittingEmptySubsequences: true
        )
        guard compos.count == 2 else { return nil }
        var key = String(compos[0]).trimmingCharacters(in: .whitespacesAndNewlines)
        var value = String(compos[1]).trimmingCharacters(in: .whitespacesAndNewlines)
        guard key.hasPrefix("["),
              key.hasSuffix("]"),
              value.hasPrefix("["),
              value.hasSuffix("]")
        else {
            return nil
        }
        key.removeFirst()
        key.removeLast()
        value.removeFirst()
        value.removeLast()
        return (key, value)
    }

    private func populateDeviceName(fromMeta meta: [String: String]) {
        var name: String?
        if let prefix = meta["ro.product.manufacturer"],
           let sufix = meta["ro.product.model"]
        {
            name = [prefix, sufix].joined(separator: " ")
        }
        if name == nil, let retry = meta["persist.sys.device_name"] {
            name = retry
        }
        guard let name = name else { return }
        DispatchQueue.withMainAndWait {
            guard self.deviceName != name else {
                return
            }
            self.deviceName = name
        }
    }
}
