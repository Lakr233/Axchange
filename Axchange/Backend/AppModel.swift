//
//  AppModel.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/26.
//

import SwiftUI

class AppModel: ObservableObject {
    static let shared = AppModel()

    @Published var isScanningDevices = false

    @Published var devices = [Device]()
}
