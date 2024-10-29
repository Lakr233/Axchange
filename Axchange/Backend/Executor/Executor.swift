//
//  Executor.swift
//  Action
//
//  Created by Lakr Aream on 2022/7/26.
//

import AuxiliaryExecute
import Combine
import Foundation

public final class Executor: ObservableObject {
    static let shared = Executor()

    private let scanQueue = DispatchQueue(label: "wiki.qaq.adb.scan")
    private var subprocessIdentifiers = Set<pid_t>() {
        didSet {
            print("[*] subprocess poll changed: \(subprocessIdentifiers)")
        }
    }

    private var subprocessIdentifiersLock = NSLock()

    let adbServerPort = 5037
    let adbBinaryLocation = Bundle.main.url(forAuxiliaryExecutable: "adb")!
    private(set) var version: String = ""

    enum ADBServiceType: Equatable {
        case pending
        case systemProvided
        case applicationProvided
    }

    @Published var serviceType: ADBServiceType = .pending

    private init() {
        setenv("ANDROID_ADB_SERVER_PORT", "\(adbServerPort)", 1)

        version = executeADB(withParameters: ["version"])
            .stdout
            .components(separatedBy: "\n")
            .first?
            .components(separatedBy: " ")
            .last
            ?? "0"

        startServerWorker(port: adbServerPort)
        waitForFirstServiceHeartbeat()

        scanForDevices()
    }

    func waitForFirstServiceHeartbeat() {
        let sem = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            defer { sem.signal() }
            let beginDate = Date()
            while Date().timeIntervalSince(beginDate) < 3 {
                while self.queryServiceVersion() <= 0 {
                    usleep(250_000) // 0.25s
                }
                let interval = Date().timeIntervalSince(beginDate)
                print(String(format: "[*] initial wait for adb service acknowledged in %4fs", interval))
                break
            }
        }
        sem.wait()
    }

    func insertSubprocessIdentifier(_ pid: pid_t) {
        subprocessIdentifiersLock.lock()
        subprocessIdentifiers.insert(pid)
        subprocessIdentifiersLock.unlock()
    }

    func removeSubprocessIdentifier(_ pid: pid_t) {
        subprocessIdentifiersLock.lock()
        subprocessIdentifiers.remove(pid)
        subprocessIdentifiersLock.unlock()
    }

    func killallSubprocess() {
        subprocessIdentifiersLock.lock()
        for pid in subprocessIdentifiers {
            kill(pid, SIGKILL)
        }
        subprocessIdentifiers.removeAll()
        subprocessIdentifiersLock.unlock()
    }

    func listDevices() -> [(String, Device.Status)] {
        let recipe = executeADB(
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
                AppModel.shared.isScanningDevices = true
                previousDevices = AppModel.shared.devices
            }
            print("[*] scanning for devices")
            defer {
                print("[*] scan completed")
                DispatchQueue.withMainAndWait {
                    AppModel.shared.isScanningDevices = false
                }
            }

            var deviceBuilder = [Device]()

            let listResults = self.listDevices()

            // update status if already exists
            for alreadyExistsDevice in previousDevices {
                let updater = listResults.first { object in
                    object.0 == alreadyExistsDevice.adbIdentifier
                }
                guard let updater else { continue }
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

            usleep(500_000)

            DispatchQueue.withMainAndWait {
                AppModel.shared.devices = deviceBuilder
            }
        }
    }
}
