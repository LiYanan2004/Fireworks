//
//  VisualEffectView.swift
//  Fireworks
//
//  Created by LiYanan2004 on 2022/12/31.
//

import SwiftUI

#if os(macOS)
struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
#endif
