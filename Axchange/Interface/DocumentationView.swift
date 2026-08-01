//
//  DocumentationView.swift
//  Axchange
//
//  Created by 秋星桥 on 2026/8/1.
//

import SwiftUI
import WebKit

struct DocumentationView: NSViewRepresentable {
    let url: URL

    init(url: URL = Documentation.homeURL) {
        self.url = url
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        if let handler = context.coordinator.schemeHandler {
            configuration.setURLSchemeHandler(handler, forURLScheme: Documentation.scheme)
        }

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.setValue(false, forKey: "drawsBackground")
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_: WKWebView, context _: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        /// Schemes a click inside the documentation may hand over to the system.
        private static let externalSchemes: Set<String> = ["http", "https", "mailto"]

        let schemeHandler: DocumentationSchemeHandler?

        override init() {
            schemeHandler = Documentation.root.map { DocumentationSchemeHandler(root: $0) }
            super.init()
        }

        func webView(
            _: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void,
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            // The documentation is self contained, everything else is either an
            // outbound link the user clicked or something we did not ask for.
            guard url.scheme != Documentation.scheme else {
                decisionHandler(.allow)
                return
            }

            decisionHandler(.cancel)

            guard navigationAction.navigationType == .linkActivated,
                  let scheme = url.scheme?.lowercased(),
                  Self.externalSchemes.contains(scheme)
            else { return }
            NSWorkspace.shared.open(url)
        }

        func webView(
            _: WKWebView,
            createWebViewWith _: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures _: WKWindowFeatures,
        ) -> WKWebView? {
            // `target="_blank"` links never get their own web view, the policy
            // handler above already routed them to the browser.
            if let url = navigationAction.request.url,
               let scheme = url.scheme?.lowercased(),
               Self.externalSchemes.contains(scheme) {
                NSWorkspace.shared.open(url)
            }
            return nil
        }
    }
}

final class DocumentationWindowController: NSWindowController, NSWindowDelegate {
    private static var current: DocumentationWindowController?

    static func show(document: String? = nil) {
        assert(Thread.isMainThread)

        guard Documentation.isAvailable else {
            assertionFailure("documentation bundle is missing from the app")
            return
        }

        if let current {
            current.showWindow(nil)
            current.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let url = document.map { Documentation.url(forDocument: $0) } ?? Documentation.homeURL
        let window = NSWindow(
            contentRect: .init(x: 0, y: 0, width: 1100, height: 720),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false,
        )
        window.title = NSLocalizedString("Axchange Help", comment: "")
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.minSize = .init(width: 640, height: 480)
        window.center()
        window.contentView = NSHostingView(rootView: DocumentationView(url: url))
        window.isReleasedWhenClosed = false

        let controller = DocumentationWindowController(window: window)
        window.delegate = controller
        current = controller

        controller.showWindow(nil)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_: Notification) {
        Self.current = nil
    }
}
