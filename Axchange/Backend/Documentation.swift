//
//  Documentation.swift
//  Axchange
//
//  Created by 秋星桥 on 2026/8/1.
//

import Foundation
import UniformTypeIdentifiers
import WebKit

/// The documentation is a VitePress site built into `Documentation.bundle` by
/// `Scripts/BuildDocs` and embedded in the app. It is written against an
/// absolute base path, so it is served from a custom scheme rather than
/// `file://` where absolute paths would escape the bundle.
enum Documentation {
    static let scheme = "axchange-help"
    static let host = "documentation"

    static let root: URL? = Bundle.main.url(forResource: "Documentation", withExtension: "bundle")

    static var isAvailable: Bool {
        guard let root else { return false }
        let home = root.appendingPathComponent("\(fallbackLocaleDirectory)/documents/welcome.html")
        return FileManager.default.fileExists(atPath: home.path)
    }

    /// The locale directories published by the site, in the order they are matched.
    private static let localeDirectories = ["zh", "ja", "en"]
    private static let fallbackLocaleDirectory = "en"

    static var preferredLocaleDirectory: String {
        for language in Locale.preferredLanguages {
            let code = String(language.prefix(2)).lowercased()
            if localeDirectories.contains(code) { return code }
        }
        return fallbackLocaleDirectory
    }

    static func url(forDocument document: String) -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "/\(preferredLocaleDirectory)/documents/\(document).html"
        guard let url = components.url else {
            assertionFailure()
            return URL(string: "\(scheme)://\(host)/")!
        }
        return url
    }

    static var homeURL: URL { url(forDocument: "welcome") }
}

final class DocumentationSchemeHandler: NSObject, WKURLSchemeHandler {
    private let root: URL
    private var activeTasks: Set<ObjectIdentifier> = []

    init(root: URL) {
        self.root = root.standardizedFileURL
        super.init()
    }

    func webView(_: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        assert(Thread.isMainThread)
        let identifier = ObjectIdentifier(urlSchemeTask as AnyObject)
        activeTasks.insert(identifier)
        defer { activeTasks.remove(identifier) }

        guard let url = urlSchemeTask.request.url else {
            finish(urlSchemeTask, identifier: identifier, error: URLError(.badURL))
            return
        }

        guard let file = resolve(url) else {
            respondNotFound(to: urlSchemeTask, identifier: identifier, url: url)
            return
        }

        do {
            let data = try Data(contentsOf: file)
            respond(to: urlSchemeTask, identifier: identifier, url: url, data: data, statusCode: 200, file: file)
        } catch {
            finish(urlSchemeTask, identifier: identifier, error: error)
        }
    }

    func webView(_: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        assert(Thread.isMainThread)
        activeTasks.remove(ObjectIdentifier(urlSchemeTask as AnyObject))
    }

    /// Maps a request path onto a file inside the bundle, applying the same
    /// index and extension fallbacks a static web server would.
    private func resolve(_ url: URL) -> URL? {
        var path = url.path
        if path.isEmpty { path = "/" }
        if path.hasSuffix("/") { path += "index.html" }

        let candidate = root.appendingPathComponent(path).standardizedFileURL
        guard candidate.path == root.path || candidate.path.hasPrefix(root.path + "/") else {
            return nil // path traversal
        }

        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: candidate.path, isDirectory: &isDirectory) {
            guard isDirectory.boolValue else { return candidate }
            let index = candidate.appendingPathComponent("index.html")
            return FileManager.default.fileExists(atPath: index.path) ? index : nil
        }

        guard candidate.pathExtension.isEmpty else { return nil }
        let html = candidate.appendingPathExtension("html")
        return FileManager.default.fileExists(atPath: html.path) ? html : nil
    }

    private func respondNotFound(to task: WKURLSchemeTask, identifier: ObjectIdentifier, url: URL) {
        let notFound = root.appendingPathComponent("404.html")
        let data = (try? Data(contentsOf: notFound)) ?? Data()
        respond(to: task, identifier: identifier, url: url, data: data, statusCode: 404, file: notFound)
    }

    private func respond(
        to task: WKURLSchemeTask,
        identifier: ObjectIdentifier,
        url: URL,
        data: Data,
        statusCode: Int,
        file: URL,
    ) {
        let mimeType = UTType(filenameExtension: file.pathExtension)?.preferredMIMEType
            ?? "application/octet-stream"
        guard let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: [
                "Content-Type": mimeType,
                "Content-Length": String(data.count),
                "Cache-Control": "no-cache",
            ],
        ) else {
            finish(task, identifier: identifier, error: URLError(.cannotParseResponse))
            return
        }

        guard activeTasks.contains(identifier) else { return }
        task.didReceive(response)
        guard activeTasks.contains(identifier) else { return }
        task.didReceive(data)
        guard activeTasks.contains(identifier) else { return }
        task.didFinish()
    }

    private func finish(_ task: WKURLSchemeTask, identifier: ObjectIdentifier, error: Error) {
        guard activeTasks.contains(identifier) else { return }
        task.didFailWithError(error)
    }
}
