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
        let commands = CommandMenu("烟花控制") {
            Button("少一点烟花") {
                container.rootCell.birthRate = min(1, container.rootCell.lastBirth - 0.5)
            }
            .keyboardShortcut(.downArrow)
            
            Button("多一点烟花") {
                container.rootCell.birthRate += 0.5
            }
            .keyboardShortcut(.upArrow)
        }
#if os(macOS)
        conditionalWindowScene()
            .commands { commands }
            .windowStyle(.hiddenTitleBar)
#else
        WindowGroup {
            ContentView(container: container)
        }
        .commands { commands }
#endif
    }
    
#if os(macOS)
    func conditionalWindowScene() -> some Scene {
        if #available(macOS 13.0, *) {
            return Window("Firworks", id: "MAIN") {
                ContentView(container: container)
            }
        } else {
            return WindowGroup {
                ContentView(container: container)
            }
        }
    }
#endif
}
