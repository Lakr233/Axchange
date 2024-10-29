//
//  MainView.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/26.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            SidebarView()
            WelcomeView()
        }
        .navigationTitle("Axchange")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    NSApp.keyWindow?.firstResponder?.tryToPerform(
                        #selector(NSSplitViewController.toggleSidebar(_:)),
                        with: nil
                    )
                } label: {
                    Label("Toggle Sidebar", systemImage: "sidebar.leading")
                }
            }
        }
    }
}
