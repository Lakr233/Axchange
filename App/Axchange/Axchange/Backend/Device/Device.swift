//
//  Device.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/26.
//

import AuxiliaryExecute
import Foundation

class Device: ObservableObject, Equatable, Identifiable {
    // use adb name as fully qualified device name
    var id: String { adbIdentifier }
    let adbIdentifier: String

    enum Status: String, Equatable, Hashable, Codable {
        case authorized
        case unauthorized
        // we do not support connect over wifi so
        // case other
    }

    @Published var deviceName: String?
    @Published var deviceStatus: Status

    @Published var deviceLog: [DeviceExecLog] = []

    struct DeviceExecLog: Identifiable, Hashable, Equatable {
        var id: UUID = .init()
        let command: String
        let recipt: AuxiliaryExecute.ExecuteReceipt

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        static func == (lhs: DeviceExecLog, rhs: DeviceExecLog) -> Bool {
            lhs.id == rhs.id
        }
    }

    let adbQueue: DispatchQueue!

    var interfaceName: String {
        if let deviceName = deviceName {
            return deviceName
        }
        return "[\(adbIdentifier)]"
    }

    init(identifier: String, status: Status = .unauthorized) {
        adbIdentifier = identifier
        adbQueue = DispatchQueue(label: "wiki.qaq.device.\(adbIdentifier)")
        _deviceStatus = Published<Status>(initialValue: status)
    }

    static func == (lhs: Device, rhs: Device) -> Bool {
        lhs.adbIdentifier == rhs.adbIdentifier
    }
}
