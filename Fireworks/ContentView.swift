//
//  ContentView.swift
//  Fireworks
//
//  Created by LiYanan2004 on 2022/12/31.
//

import SwiftUI

#if os(macOS)
typealias PlatformImage = NSImage
#else
typealias PlatformImage = UIImage
#endif

struct ContentView: View {
    @ObservedObject var container: FireworksContainer
    @State private var image: Image?
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            TimelineView(.animation) { timeline in
                let now = timeline.date.timeIntervalSinceReferenceDate
                
                Canvas(rendersAsynchronously: true) { context, size in
                    container.update(at: now, in: size)
                    context.blendMode = .screen
                    
                    container.forEachPaticle { particle in
                        var innerContext = context
                        innerContext.opacity = particle.opacity
                        innerContext.fill(Ellipse().path(in: particle.frame),
                                          with: particle.shading)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { container.addParticle(at: $0.location, in: size) }
                )
            }
        }
        .blendMode(image == nil ? .normal : .plusLighter)
        .conditional {
            if #available(iOS 16.0, *) {
                $0.dropDestination(for: Data.self) { items, _ in
                    guard let imageData = items.first else { return false }
                    
                    Task.detached {
                        if let image = PlatformImage(data: imageData) {
                            Task { @MainActor in
                                self.container.hasPhoto = true
#if os(macOS)
                                self.image = Image(nsImage: image)
#else
                                self.image = Image(uiImage: image)
#endif
                            }
                        }
                    }
                    
                    return true
                }
            }
        }
        .background {
            if let image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                #if os(macOS)
                VisualEffectView()
                #endif
            }
        }
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(container: FireworksContainer())
    }
}

extension View {
    @ViewBuilder
    func conditional<V: View>(@ViewBuilder apply: @escaping (Self) -> V) -> some View {
        apply(self)
    }
}
