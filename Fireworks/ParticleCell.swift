//
//  ParticleCell.swift
//  Fireworks
//
//  Created by LiYanan2004 on 2022/12/31.
//

import SwiftUI
import AVKit

struct ParticleCell {
    typealias Generator = (inout Particle) -> Void
    
    var time = 0.0
    var birthRate: Double = 0.0
    var beginEmitting: Double = 0.0
    var endEmitting = Double.infinity
    var lastBirth: Double = 0.0
    var generator: Generator = { _ in }
    var particles = [Particle]()
    var isActive: Bool { !particles.isEmpty }

    let player = AVPlayer(url: Bundle.main.url(forResource: "sound", withExtension: "m4a")!)
    
    mutating func updateOldParticles(delta: Double) {
        var index = 0
        let oldN = particles.count
        var newN = oldN
        
        while index < newN {
            if particles[index].update(delta: delta) {
                index += 1
            } else {
                newN -= 1
                particles.swapAt(index, newN)
            }
        }
        if newN < oldN {
            particles.removeSubrange(newN ..< oldN)
        }
    }
    
    mutating func createNewParticles(delta: Double, newParticle: () -> Particle) {
        time += delta
        guard lastBirth < endEmitting + beginEmitting else {
            lastBirth = time
            return
        }
        
        let birthInterval = 1.0 / birthRate
        while time - lastBirth >= birthInterval {
            lastBirth += birthInterval
            guard lastBirth < endEmitting + beginEmitting else { continue }
            
            var particle = newParticle()
            generator(&particle)
            if particle.update(delta: time - lastBirth) {
                particles.append(particle)
            }
        }
    }
    
    func forEachParticle(do body: (Particle) -> Void) {
        for index in particles.indices {
            if let cell = particles[index].cell {
                // In rootCell, every particle has a cell.
                cell.forEachParticle(do: body)
            } else {
                body(particles[index])
            }
        }
    }
    
    func playSound() {
        guard beginEmitting > 0.0 else { return }
        player.volume = 0.1
        
        player.seek(to: CMTimeMakeWithSeconds(max(0, 3.0 - beginEmitting), preferredTimescale: 1000))
        player.play()
    }
}

struct Particle {
    var lifetime: Double = 0.0
    var color: Color = .green
    var size: CGFloat = 3
    var position: CGPoint = .zero
    var liftingPosition: CGPoint = .zero
    var opacity: Double = 0.0
    var cell: ParticleCell?
    
    var sizeSpeed: Double = 0.0
    var velocity: CGSize = .zero
    var acceleration: CGSize = .zero
    var opacitySpeed: Double = 0.0

    var lifting: Bool = false
    
    mutating func update(delta: Double) -> Bool {
        lifetime -= delta
        
        if !lifting {
            size += sizeSpeed * delta
            position.x += velocity.width * delta
            position.y += velocity.height * delta
            velocity.width += acceleration.width * delta
            velocity.height += acceleration.height * delta
        }
        
        opacity += opacitySpeed * delta
        
        var active = lifetime > 0
        
        if var cell = cell {
            cell.updateOldParticles(delta: delta)
            if active {
                cell.createNewParticles(delta: delta) {
                    if liftingPosition.y > position.y {
                        liftingPosition.y -= 0.1
                        lifetime += delta
                        return Particle(color: color, position: liftingPosition, lifting: true)
                    } else {
                        return Particle(color: color, position: position)
                    }
                }
            }
            active = active || cell.isActive
            self.cell = cell
        } else if opacity <= 0 || size <= 0 {
            active = false
        }
        
        return active
    }

    var shading: GraphicsContext.Shading {
        .color(color)
    }
    
    var frame: CGRect {
        CGRect(origin: position, size: CGSize(width: size, height: size))
    }
}
