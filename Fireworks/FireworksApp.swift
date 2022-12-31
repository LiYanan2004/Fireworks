//
//  FireworksApp.swift
//  Fireworks
//
//  Created by LiYanan2004 on 2022/12/31.
//

import SwiftUI

@main
struct FireworksApp: App {
    @StateObject private var container = FireworksContainer()
    
    var body: some Scene {
        Window("Firworks", id: "MAIN") {
            ContentView(container: container)
        }
        .commands {
            CommandMenu("烟花控制") {
                Button("少一点烟花") {
                    container.rootCell.birthRate = min(1, container.rootCell.lastBirth - 0.5)
                }
                .keyboardShortcut(.downArrow)
                
                Button("多一点烟花") {
                    container.rootCell.birthRate += 0.5
                }
                .keyboardShortcut(.upArrow)
            }
        }
        .windowStyle(.hiddenTitleBar)
    }
}
