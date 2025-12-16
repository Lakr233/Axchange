//
//  RemotePathTests.swift
//  AxchangeTests
//
//  Created by qaq on 15/12/2025.
//

import Foundation
import Testing

@testable @preconcurrency import Axchange

// MARK: - RemotePath Unit Tests

@Suite(.serialized)
struct RemotePathTests {
    @Test func remotePathDoesNotNormalizeUnicode() async throws {
        let dir = "/sdcard"
        let nfc = "\u{304C}" // が (precomposed)

        let url = URL(fileURLWithPath: dir).appendingPathComponent(nfc)

        let urlComponentScalars = url.lastPathComponent.unicodeScalars.map(\.value)
        let originalScalars = nfc.unicodeScalars.map(\.value)

        #expect(urlComponentScalars != originalScalars)

        let joined = RemotePath.join(dir: dir, component: nfc)
        let joinedScalars = (joined as NSString).lastPathComponent.unicodeScalars.map(\.value)

        #expect(joinedScalars == originalScalars)
    }

    @Test func remotePathCandidatesContainBothForms() async throws {
        let nfc = "\u{304C}" // が
        let nfd = "\u{304B}\u{3099}" // か + combining dakuten

        let fromNfc = Set(RemotePath.candidates(for: "/sdcard/" + nfc))
        let fromNfd = Set(RemotePath.candidates(for: "/sdcard/" + nfd))

        #expect(fromNfc.intersection(fromNfd).isEmpty == false)
    }

    @Test func remotePathNormalize() async throws {
        #expect(RemotePath.normalize("") == "/")
        #expect(RemotePath.normalize("/") == "/")
        #expect(RemotePath.normalize("/sdcard") == "/sdcard")
        #expect(RemotePath.normalize("/sdcard/") == "/sdcard")
        #expect(RemotePath.normalize("/sdcard//") == "/sdcard")
        #expect(RemotePath.normalize("sdcard") == "/sdcard")
    }

    @Test func remotePathJoin() async throws {
        #expect(RemotePath.join(dir: "/", component: "sdcard") == "/sdcard")
        #expect(RemotePath.join(dir: "/sdcard", component: "Music") == "/sdcard/Music")
        #expect(RemotePath.join(dir: "/sdcard/", component: "Music") == "/sdcard/Music")
    }

    @Test func remotePathDeletingLastComponent() async throws {
        #expect(RemotePath.deletingLastComponent("/") == "/")
        #expect(RemotePath.deletingLastComponent("/sdcard") == "/")
        #expect(RemotePath.deletingLastComponent("/sdcard/Music") == "/sdcard")
        #expect(RemotePath.deletingLastComponent("/sdcard/Music/file.mp3") == "/sdcard/Music")
    }

    @Test func remotePathLastComponent() async throws {
        #expect(RemotePath.lastComponent("/") == "/")
        #expect(RemotePath.lastComponent("/sdcard") == "sdcard")
        #expect(RemotePath.lastComponent("/sdcard/Music") == "Music")
    }

    @Test func remotePathComponents() async throws {
        #expect(RemotePath.pathComponents("/") == ["/"])
        #expect(RemotePath.pathComponents("/sdcard") == ["/", "sdcard"])
        #expect(RemotePath.pathComponents("/sdcard/Music") == ["/", "sdcard", "Music"])
    }

    @Test func remotePathSliceToNthComponent() async throws {
        #expect(RemotePath.sliceToNthComponent("/sdcard/Music/file.mp3", 0) == "/")
        #expect(RemotePath.sliceToNthComponent("/sdcard/Music/file.mp3", 1) == "/sdcard")
        #expect(RemotePath.sliceToNthComponent("/sdcard/Music/file.mp3", 2) == "/sdcard/Music")
    }
}
