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
        .preferredColorScheme(.dark)
        .conditional {
            if #available(iOS 16.0, macOS 13.0, *) {
                $0.dropDestination(for: Data.self, action: handleDrop(items:location:))
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
    
    private func handleDrop(items: [Data], location: CGPoint) -> Bool {
        guard let imageData = items.first else { return false }
        
        Task.detached {
            if let image = PlatformImage(data: imageData) {
                Task { @MainActor in
                    self.container.hasPhoto = true
                    self.image = Image(platformImage: image)
                }
            }
        }
        
        return true
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

extension Image {
    init(platformImage: PlatformImage) {
#if os(macOS)
        self.init(nsImage: platformImage)
#else
        self.init(uiImage: platformImage)
#endif
    }
}
