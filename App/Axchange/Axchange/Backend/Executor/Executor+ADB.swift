//
//  Executor+ADB.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/26.
//

import AuxiliaryExecute
import Foundation

extension Executor {
    static let adbBinaryLocation = Bundle
        .main
        .url(forResource: "adb", withExtension: nil, subdirectory: "Auxiliary")!

    static let version = "Android Debug Bridge version 1.0.41"

    static func executeADB(
        withParameters parameters: [String],
        timeout: Double = -1,
        setPid: ((pid_t) -> Void)? = nil,
        output: ((String) -> Void)? = nil
    ) -> AuxiliaryExecute.ExecuteReceipt {
        AuxiliaryExecute.spawn(
            command: adbBinaryLocation.path,
            args: parameters,
            environment: [:],
            timeout: timeout,
            setPid: setPid,
            output: output
        )
    }

    static func executeADB(
        forDeviceWithName deviceName: String,
        withParameters parameters: [String],
        timeout: Double = -1,
        setPid: ((pid_t) -> Void)? = nil,
        output: ((String) -> Void)? = nil
    ) -> AuxiliaryExecute.ExecuteReceipt {
        executeADB(
            withParameters: ["-s", deviceName] + parameters,
            timeout: timeout,
            setPid: setPid,
            output: output
        )
    }

    static func resetADB() {
        _ = AuxiliaryExecute.spawn(command: "/usr/bin/pkill", args: ["-9", "adb"])
    }
}
