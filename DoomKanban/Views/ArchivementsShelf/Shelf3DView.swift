//
//  test.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 8/8/24.
//
// - Important: To make this work I've need to do this https://forums.developer.apple.com/forums/thread/710843?answerId=764027022#764027022
//

import SwiftUI
import RealityKit

struct Shelf3DView: View {
    @Environment(\.openWindow) private var openWindow
    let defaultSize: Size3D
    private let vm = Shelf3dViewModel()
    
    var body: some View {
        GeometryReader3D { proxy in
            RealityView { content, attachments in
                content.add(vm.scaledRootEntity)
                vm.scale(entity: vm.scaledRootEntity, content: content, proxy: proxy, defaultSize: defaultSize)
                await createShelf(content, attachments)
                floor()
                
            } update: { content, attachments in
                // Scale the root entity based on the window zoom level during content updates
                vm.scale(entity: vm.scaledRootEntity, content: content, proxy: proxy, defaultSize: defaultSize)
            } placeholder: {
                ProgressView() // Shows a progress view while the 3D content is being loaded
            } attachments: {
                // Attachments for the first shelf coin
                ForEach(vm.createAttachments(for: vm.firstShelfCoin), id: \.id) { attachment in
                    attachment
                }
                // Attachments for the second shelf coins
                ForEach(vm.createAttachments(for: vm.secondShelfCoins), id: \.id) { attachment in
                    attachment
                }
                // Attachments for the third shelf coins
                ForEach(vm.createAttachments(for: vm.thirdShelfCoins), id: \.id) { attachment in
                    attachment
                }
            }
        }
        .toolbar {
            createBackButton()
        }.onAppear {
            vm.loadUnlockedAchievements()
        }
    }
}

// - MARK: Subviews
extension Shelf3DView {
    /// Create the floor entity with static physics
    private func floor() {
        let floorEntity = ModelEntity(mesh: .generateBox(size: [0.01, 0.01, 0.01])) // Creates a thin box to simulate a flat surface
        floorEntity.model?.materials = [SimpleMaterial(color: .black, isMetallic: true)]
        let floorShape = ShapeResource.generateBox(size: [2, 0.01, 2])
        floorEntity.physicsBody = PhysicsBodyComponent(shapes: [floorShape], density: 10, mode: .static)
        floorEntity.collision = CollisionComponent(shapes: [floorShape])
        floorEntity.position = [0, -1.25, 0] // Adjust floor height
        vm.scaledRootEntity.addChild(floorEntity)
    }
    
    private func createShelf(_ content: RealityViewContent, _ attachments: RealityViewAttachments) async {
        if let shelfEntity = try? await ModelEntity(named: "Round Book Shelf") {
            // Adjust shelf entity and add physics
            shelfEntity.scale = [1.0, 1.0, 1.0]
            shelfEntity.transform.translation.y = 0 // Initial position
            
            let shelfShape = ShapeResource.generateBox(size: [1.0, 1.0, 0.5])
            shelfEntity.physicsBody = PhysicsBodyComponent(shapes: [shelfShape], mass: 8.0, material: .generate(friction: 0.8, restitution: 0.1), mode: .dynamic)
            shelfEntity.collision = CollisionComponent(shapes: [shelfShape])
            
            vm.scaledRootEntity.addChild(shelfEntity)
            
            await vm.createFirst(shelfEntity: shelfEntity, in: content, with: attachments)
            await vm.createSecond(shelfEntity: shelfEntity, in: content, with: attachments)
            await vm.createThird(shelfEntity: shelfEntity, in: content, with: attachments)
        }
    }
    
    private func createBackButton() -> ToolbarItem<(), Button<some View>> {
        return ToolbarItem(placement: .bottomOrnament) {
            // Back button for navigation
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    openWindow(id: "InitialMenu")
                }
            }) {
                Image(systemName: "arrow.backward")
                    .opacity(0.5)
                    .glassBackgroundEffect()
                    .font(.largeTitle)
                    .padding()
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    let defaultSize = Size3D(width: 2, height: 2, depth: 2)
    Shelf3DView(defaultSize: defaultSize)
}

