//
//  Executor.swift
//  Action
//
//  Created by Lakr Aream on 2022/7/26.
//

import AuxiliaryExecute
import Foundation

// do the test job for each version bro

public final class Executor {
    static let shared = Executor()

    private let scanQueue = DispatchQueue(label: "wiki.qaq.adb.scan")

    private init() {
        let receipt = Self.executeADB(withParameters: ["version"], timeout: 3, output: nil)
        let versionOutput = receipt.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        guard receipt.exitCode == 0, versionOutput.contains(Self.version) /* , username != "root" */ else {
            fatalError("Malformed application permission")
        }
        print("====== ADB ======")
        print(versionOutput)
        print("=================")
        scanForDevices()
    }

    func listDevices() -> [(String, Device.Status)] {
        let recipe = Self.executeADB(
            withParameters: ["devices"],
            timeout: 6
        )
        let header = "List of devices attached\n"
        guard recipe.exitCode == 0,
              recipe.stdout.hasPrefix(header)
        else {
            return []
        }
        return recipe.stdout
            .dropFirst(header.count)
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .filter { $0.contains("\t") }
            .compactMap { invokeDevice(fromLine: $0) }
    }

    private func invokeDevice(fromLine line: String) -> (String, Device.Status)? {
        let item = line.components(separatedBy: "\t")
            .filter { !$0.isEmpty }
        guard item.count == 2,
              !item[0].isEmpty,
              !item[1].isEmpty
        else {
            return nil
        }
        let status: Device.Status = item[1] == "device"
            ? Device.Status.authorized
            : Device.Status.unauthorized
        return (item[0], status)
    }

    func scanForDevices() {
        scanQueue.async {
            var previousDevices = [Device]()
            DispatchQueue.withMainAndWait {
                AppStatus.shared.isScanningDevices = true
                previousDevices = AppStatus.shared.devices
            }
            print("[*] scanning for devices")
            defer {
                print("[*] scan completed")
                DispatchQueue.withMainAndWait {
                    AppStatus.shared.isScanningDevices = false
                }
            }

            var deviceBuilder = [Device]()

            let listResults = self.listDevices()

            // update status if already exists
            for alreadyExistsDevice in previousDevices {
                let updater = listResults.first { object in
                    object.0 == alreadyExistsDevice.adbIdentifier
                }
                guard let updater = updater else { continue }
                deviceBuilder.append(alreadyExistsDevice)
                DispatchQueue.withMainAndWait {
                    alreadyExistsDevice.deviceStatus = updater.1
                }
            }

            // for the new devices
            for updater in listResults {
                let existsFinder = deviceBuilder.firstIndex { object in
                    object.adbIdentifier == updater.0
                }
                guard existsFinder == nil else {
                    continue
                }
                deviceBuilder.append(.init(identifier: updater.0, status: updater.1))
            }

            for device in deviceBuilder {
                device.requestPopulateDeviceProperty()
            }

            sleep(1)

            DispatchQueue.withMainAndWait {
                AppStatus.shared.devices = deviceBuilder
            }
        }
    }
}
