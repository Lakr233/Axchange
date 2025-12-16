//
//  Executor+Ping.swift
//  Axchange
//
//  Created by 秋星桥 on 2024/11/11.
//

import Foundation
import Network

extension Executor {
    enum QueryError: Error {
        case unreachable
        case invalidMessage
        case failedSend
        case failedRecived
        case timeout
    }

    func queryServiceVersion(overPort port: Int = 5037) -> Int {
        assert(!Thread.isMainThread)
        let sem = DispatchSemaphore(value: 0)
        let command = "host:version"
        var version = 0
        queryService(command: command, overPort: port) { result in
            if case let .success(data) = result,
               let versionString = String(data: data, encoding: .utf8)
            { version = Int(versionString) ?? 0 }
            sem.signal()
        }
        sem.wait()
        return version
    }

    func queryService(command: String, overPort port: Int = 5037, completion: @escaping (Result<Data, QueryError>) -> Void) {
        let connection = NWConnection(
            host: NWEndpoint.Host("localhost"),
            port: NWEndpoint.Port(integerLiteral: UInt16(port)),
            using: .tcp,
        )

        var completionCalled = false
        let completion: (Result<Data, QueryError>) -> Void = { input in
            guard !completionCalled else { return }
            connection.forceCancel()
            completionCalled = true
            completion(input)
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            guard !completionCalled else { return }
            completion(.failure(.timeout))
        }

        guard let command = String(format: "%04X%@", command.count, command).data(using: .utf8) else {
            completion(.failure(.invalidMessage))
            return
        }

        connection.start(queue: .global())
        connection.send(content: command, completion: .contentProcessed { error in
            if let error {
                print("[!] failed to send message: \(error.localizedDescription)")
                completion(.failure(.failedSend))
                return
            }
        })
        connection.receive(minimumIncompleteLength: 8, maximumLength: 8) { content, _, _, error in
            guard let content else {
                print("[!] failed to send message: \(error?.localizedDescription ?? "?")")
                completion(.failure(.failedRecived))
                return
            }
            let resp = String(data: content[0 ..< 4], encoding: .utf8) ?? ""
            let length = String(data: content[4 ..< 8], encoding: .utf8).flatMap { Int($0, radix: 16) } ?? 0

            guard resp == "OKAY" else {
                completion(.failure(.failedRecived))
                return
            }

            if length == 0 {
                completion(.success(.init()))
                return
            }

            connection.receive(minimumIncompleteLength: length, maximumLength: length) { content, _, _, _ in
                guard let content, content.count == length else {
                    completion(.failure(.failedRecived))
                    return
                }
                completion(.success(content))
            }
        }
    }
}
