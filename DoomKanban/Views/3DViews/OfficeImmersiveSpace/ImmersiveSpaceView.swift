//
//  ImmersiveSpaceView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveSpaceView: View {
    @Environment(KanbanAppVM.self) var kanbanVM
    @Environment(\.openWindow) private var openWindow
    @State private var vm = ImmersiveSpaceViewModel()
    
    var body: some View {
        RealityView { content in
            Task {
                await vm.visionProPose.runArSession()
            }
            await createOfficeWithTriggerableFireAndSmokeParticles(content)
        }
        .onChange(of: kanbanVM.warningList) {
            fireControlBasedOnWarnings()
        }
    }
    
    
}

// - MARK: Subviews
extension ImmersiveSpaceView {
    /// Load the Office scene from RealityKit and create the fire and smoke entities that will be triggered by the number of warnings
    private func createOfficeWithTriggerableFireAndSmokeParticles(_ content: RealityViewContent) async {
        if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
            content.add(scene)
            
            // Create fire and smoke entities at the beginning
            vm.fireEntities = (1...3).map { scene.findEntity(named: "Fire\($0)") }
            vm.smokeEntities = (1...3).map { scene.findEntity(named: "Smoke\($0)") }
            
            // Log any missing fire or smoke entities
            vm.fireEntities.enumerated().forEach { index, entity in
                if entity == nil { print("Fire\(index + 1) entity not found") }
                else {
                    entity?.isEnabled = false
                }
            }
            vm.smokeEntities.enumerated().forEach { index, entity in
                if entity == nil { print("Smoke\(index + 1) entity not found") }
                else {
                    entity?.isEnabled = false
                }
            }
            // ⚠️ JLE: ESTO QUEDA PENDIENTE DE HABLARLO CON JULIO PARA LA V2 DE LA APP. QUIERO HACER QUE EL ESPACIO IMMERSIVO SE CIERRE SI SE SALE DEL MODELO (Es decir, si da un par de pasos hacia atrás o delante)
            // CON EL SIMULADOR SÓLO HE CONSEGUIDO MEDICIONES A 0 Y CRASHES.
            
            // Subscribe to scene updates to track the user's position
            //                content.subscribe(to: SceneEvents.Update.self) { _ in
            //                    Task {
            //                        if let mtx = await visionProPose.getTransform() {
            //                            let position = SIMD3<Float>(mtx.columns.3.x, mtx.columns.3.y, mtx.columns.3.z)
            //                            userPosition = position
            //
            //                            if userPosition.z > forwardLimit || userPosition.z < backwardLimit {
            //                                print("User out of bounds. Position: \(userPosition.z)")
            //
            //                                if immersiveSpaceOpen {
            //                                    await dismissImmersiveSpace()
            //                                    immersiveSpaceOpen = false
            //                                }
            //                            } else {
            //                                print("User within bounds. Position: \(userPosition.z)")
            //                            }
            //                        }
            //                    }
            //                }
        } else {
            print("Failed to load the scene")
        }
    }
}

// - MARK: Office dynamic changes
extension ImmersiveSpaceView {
    /// Function to control the particle emitter for fire or smoke entities
    private func controlParticleEmitter(entity: Entity?, isActive: Bool) {
        guard let entity = entity, var emitterComponent = entity.components[ParticleEmitterComponent.self] else {
            print("Could not retrieve the particle emitter")
            return
        }
        
        if isActive {
            // Activate the particle emitter
            entity.isEnabled = true
            emitterComponent.timing = .repeating(warmUp: 2, emit: .init(duration: 10), idle: .init(duration: 3))
        } else {
            // Deactivate the particle emitter. Slowly extinguish the fire.
            Task {
                emitterComponent.timing = .once(warmUp: 2, emit: .init(duration: 1))
                entity.components[ParticleEmitterComponent.self] = emitterComponent
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                emitterComponent.timing = .once(warmUp: 0, emit: .init(duration: 0))
                entity.isEnabled = false
            }
        }
        entity.components[ParticleEmitterComponent.self] = emitterComponent
    }
    
    /// Optimized function to count the number of active warnings (max 3)
    func countActiveWarnings() -> Int {
        kanbanVM.warningList
            .prefix { $0.numberOfWarnings > 0 }
            .reduce(0) { (sum, warning) -> Int in
                let newSum = sum + warning.numberOfWarnings
                return newSum > 3 ? 3 : newSum
            }
    }
    
    /// Triggers fire particles and its smoke based on the number of warnings active
    private func fireControlBasedOnWarnings() {
        let numberOfWarnings = countActiveWarnings()
        // Update fire and smoke entities based on the number of warnings
        vm.fireEntities.enumerated().forEach { index, fireEntity in
            controlParticleEmitter(entity: fireEntity, isActive: index < numberOfWarnings)
        }
        vm.smokeEntities.enumerated().forEach { index, smokeEntity in
            controlParticleEmitter(entity: smokeEntity, isActive: index < numberOfWarnings)
        }
    }
}
