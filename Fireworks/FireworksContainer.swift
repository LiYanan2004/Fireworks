//
//  FireworksContainer.swift
//  Fireworks
//
//  Created by LiYanan2004 on 2022/12/31.
//

import SwiftUI

class FireworksContainer: ObservableObject, CanvasAnimatable {
    var hasPhoto = false
    var rootCell = ParticleCell(birthRate: 3.0)
    var lastTime = Double.zero
    
    func update(at time: Double, in size: CGSize) {
        let delta = min(1.0 / 3.0, time - lastTime)
        lastTime = time
        
        rootCell.updateOldParticles(delta: delta)
        rootCell.createNewParticles(delta: delta) {
            let particle = makePaticle(in: size)
            particle.cell?.playSound()
            return particle
        }
    }
    
    func addParticle(at point: CGPoint, in size: CGSize) {
        let particle = makePaticle(at: point, in: size)
        particle.cell?.playSound()
        rootCell.particles.append(particle)
    }
    
    private func makePaticle(at location: CGPoint? = nil, in size: CGSize) -> Particle {
        var particle = Particle()
        particle.lifetime = 0.5
        particle.position = location ?? CGPoint(x: CGFloat.random(in: 100..<size.width - 100),
                                                y: CGFloat.random(in: (hasPhoto ? (0..<100) : (100..<size.height - 100))))
        particle.color = Color.allCases.randomElement()!
        particle.liftingPosition = CGPoint(x: particle.position.x, y: size.height)
        
        var particleCell = ParticleCell(birthRate: Double.random(in: 8000...24000))
        particleCell.beginEmitting = (size.height - particle.position.y) / 0.1 / particleCell.birthRate
        particleCell.endEmitting = Double.random(in: 0.1..<0.3)

        particleCell.generator = { particle in
            if particle.lifting {
                particle.lifetime = 0.15
            } else {
                let segment = 360 / Int.random(in: 10..<15)
                let ang = Angle(degrees: Double(Int.random(in: 0..<1000) / segment) * Double(segment) + Double.random(in: -3...3))
                let velocity = Double.random(in: 40..<150)
                particle.velocity = CGSize(width: velocity * sin(ang.radians), height: velocity * -cos(ang.radians))
                particle.lifetime = (velocity / 150 * 0.2 + 1.0) * size.height / 400
                particle.acceleration = CGSize(width: -particle.velocity.width / particle.lifetime,
                                               height: -particle.velocity.height / particle.lifetime + 100)
                particle.sizeSpeed = particle.size * min(0.3, velocity * 0.1)
                particle.size *= Double.random(in: 0.25..<1)
            }
            
            particle.opacity = Double.random(in: 0.5...1)
            particle.opacitySpeed = -(particle.opacity) / particle.lifetime
        }
        
        particle.cell = particleCell
        
        return particle
    }
    
    /// Calculate the total distance of a particle.
    /// Mathmatic knowledge: A = √ (B ^ 2 + C ^ 2)
    private func totalDistance(atSpeedOf velocity: CGSize, in time: Double) -> Double {
        let poweredX = pow(velocity.width * time, 2)
        let poweredY = pow(velocity.height * time, 2)
        
        return sqrt(poweredX + poweredY)
    }
    
    func forEachPaticle(do body: (Particle) -> Void) {
        rootCell.forEachParticle(do: body)
    }
}

extension Color: CaseIterable {
    public static var allCases: [Color] {
        [.green, .blue, .cyan, .yellow, .teal, .orange, .mint, .indigo]
    }
}

protocol CanvasAnimatable {
    func update(at time: Double, in size: CGSize)
}
