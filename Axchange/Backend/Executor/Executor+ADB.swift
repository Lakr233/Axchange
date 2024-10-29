//
//  Executor+ADB.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/26.
//

import AuxiliaryExecute
import Foundation

extension Executor {
    func startServerWorker(port: Int) {
        DispatchQueue.global().async {
            while true {
                defer { sleep(1) }

                if self.queryServiceVersion() > 0 {
                    DispatchQueue.main.async {
                        self.serviceType = .systemProvided
                    }
                    continue
                }

                DispatchQueue.main.async {
                    self.serviceType = .pending
                }

                print("[*] adb server not running, booting up!")
                self.startServerWorkerEx(port: port)

                DispatchQueue.main.async {
                    self.serviceType = .pending
                }
            }
        }
    }

    private func startServerWorkerEx(port: Int) {
        print("[*] adb server starting with port \(port)")
        let result = executeADB(
            withParameters: ["server", "nodaemon", "-L", "tcp:localhost:\(port)"],
            timeout: 0
        ) { pid in
            print("[*] adb server started with pid \(pid)")
            DispatchQueue.main.async {
                self.serviceType = .applicationProvided
            }
        } output: { str in
            print(str)
        }
        print("[i] adb server exited: \(result.exitCode)")
    }

    func executeADB(
        withParameters parameters: [String],
        timeout: Double = -1,
        setPid: ((pid_t) -> Void)? = nil,
        output: ((String) -> Void)? = nil
    ) -> AuxiliaryExecute.ExecuteReceipt {
        let setPid = { (_ pid: pid_t) in
            self.insertSubprocessIdentifier(pid)
            setPid?(pid)
        }
        print("[$] adb \(parameters.joined(separator: " "))")
        let ans = AuxiliaryExecute.spawn(
            command: adbBinaryLocation.path,
            args: parameters,
            environment: [:],
            timeout: timeout,
            setPid: setPid,
            output: output
        )
        removeSubprocessIdentifier(pid_t(ans.pid))
        return ans
    }

    func executeADB(
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

    func resetADB() {
        killallSubprocess()
    }
}
