//
//  App+Setup.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/26.
//

import AppKit

extension AxchangeApp {
    static let appBundleIdentifier: String = Bundle
        .main
        .bundleIdentifier ?? "wiki.qaq.unknown"

    static let appVersion: String =
        Bundle
            .main
            .infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "unknown"

    func applicationSetup() {
        assert(Thread.isMainThread)
        assert(getuid() != 0)

        print(
            """
            \(AxchangeApp.appBundleIdentifier) - \(AxchangeApp.appVersion)
            Location:
                [*] \(Bundle.main.bundleURL.path)
                [*] \(documentDirectory.path)
            Environment: uid \(getuid()) gid \(getgid())
            """
        )

        disableDebuggerIfNeeded()

        _ = Executor.shared

        #if DEBUG
            let debuggerTimer = Timer(timeInterval: 1, repeats: true) { _ in
                _ = 0
            }
            RunLoop.current.add(debuggerTimer, forMode: .common)
        #endif
    }

    private func disableDebuggerIfNeeded() {
        #if !DEBUG
            do {
                typealias ptrace = @convention(c) (_ request: Int, _ pid: Int, _ addr: Int, _ data: Int) -> AnyObject
                let open = dlopen("/usr/lib/system/libsystem_kernel.dylib", RTLD_NOW)
                if unsafeBitCast(open, to: Int.self) > 0x1024 {
                    let result = dlsym(open, "ptrace")
                    if let result = result {
                        let target = unsafeBitCast(result, to: ptrace.self)
                        _ = target(0x1F, 0, 0, 0)
                    }
                }
            }
        #endif
    }
}
