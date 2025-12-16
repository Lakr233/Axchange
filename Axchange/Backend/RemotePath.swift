//
//  RemotePath.swift
//  Axchange
//
//  Created by qaq on 2025/12/15.
//

import Foundation

enum RemotePath {
    static func normalize(_ path: String) -> String {
        var value = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.isEmpty { value = "/" }
        if !value.hasPrefix("/") { value = "/" + value }
        while value.count > 1, value.hasSuffix("/") {
            value.removeLast()
        }
        return value
    }

    static func join(dir: String, component: String) -> String {
        let normalizedDir = normalize(dir)
        guard normalizedDir != "/" else { return "/" + component }
        return normalizedDir + "/" + component
    }

    static func deletingLastComponent(_ path: String) -> String {
        let normalized = normalize(path)
        guard normalized != "/" else { return "/" }
        guard let idx = normalized.lastIndex(of: "/"), idx != normalized.startIndex else {
            return "/"
        }
        let parent = String(normalized[..<idx])
        return parent.isEmpty ? "/" : parent
    }

    static func lastComponent(_ path: String) -> String {
        let normalized = normalize(path)
        guard normalized != "/" else { return "/" }
        return (normalized as NSString).lastPathComponent
    }

    static func pathComponents(_ path: String) -> [String] {
        let normalized = normalize(path)
        if normalized == "/" { return ["/"] }
        let comps = normalized.split(separator: "/", omittingEmptySubsequences: true).map(String.init)
        return ["/"] + comps
    }

    static func sliceToNthComponent(_ path: String, _ idx: Int) -> String {
        let comps = pathComponents(path)
        guard idx >= 0, idx < comps.count else { return normalize(path) }
        if idx == 0 { return "/" }
        return "/" + comps[1 ... idx].joined(separator: "/")
    }

    static func candidates(for path: String) -> [String] {
        let normalized = normalize(path)
        let variants = [
            normalized,
            normalized.precomposedStringWithCanonicalMapping,
            normalized.decomposedStringWithCanonicalMapping,
        ]
        var seen = Set<String>()
        return variants.filter { seen.insert($0).inserted }
    }
}
