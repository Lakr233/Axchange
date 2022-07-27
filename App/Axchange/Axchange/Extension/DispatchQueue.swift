//
//  DispatchQueue.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/26.
//

import Foundation

extension DispatchQueue {
    static func withMainAndWait(_ block: @escaping () -> Void) {
        guard !Thread.isMainThread else {
            block()
            return
        }
        let sem = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            block()
            sem.signal()
        }
        sem.wait()
    }
}
