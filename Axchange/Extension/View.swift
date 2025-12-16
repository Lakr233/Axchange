//
//  View.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/26.
//

import SwiftUI

extension View {
    func usePreferredContentSize() -> some View {
        frame(
            minWidth: 400, idealWidth: 650, maxWidth: .infinity,
            minHeight: 300, idealHeight: 555, maxHeight: .infinity,
            alignment: .center,
        )
    }
}
