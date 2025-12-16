//
//  UnauthorizedView.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/27.
//

import ColorfulX
import SwiftUI

struct UnauthorizedView: View {
    let device: Device

    var errorIcon: some View {
        ZStack {
            Image(systemName: "person.crop.circle.badge.xmark")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(.pink)
        }
        .frame(width: 60, height: 60, alignment: .center)
    }

    var body: some View {
        ZStack {
            VStack {
                errorIcon
                Text("Device \(device.adbIdentifier) is unauthorized")
                    .font(.system(.headline, design: .rounded))
            }
            VStack {
                Spacer()
                Text("Open your phone to authorize connect request.")
                    .font(.system(.footnote, design: .rounded))
                    .opacity(0.5)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ColorfulView(color: .sunset, frameLimit: .constant(30))
                .opacity(0.1)
                .ignoresSafeArea(),
        )
        .navigationTitle("Permission Denied")
    }
}
