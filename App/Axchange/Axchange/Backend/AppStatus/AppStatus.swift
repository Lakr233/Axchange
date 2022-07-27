//
//  AppStatus.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/26.
//

import SwiftUI

class AppStatus: ObservableObject {
    static let shared = AppStatus()

    @Published var isScanningDevices = false

    @Published var devices = [Device]()
}
