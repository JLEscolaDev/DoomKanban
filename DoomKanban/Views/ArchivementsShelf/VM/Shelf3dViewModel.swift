//
//  Shelf3dViewModel.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 12/9/24.
//

import SwiftUI
import RealityKit
import GameKit

@Observable
class Shelf3dViewModel {
    // Rotation angle for the coins' animation
    private var rotationAngle: Double = 0.0

    // Dynamically loaded unlocked achievements from Game Center
    var unlockedCoins: Set<String> = []
    var lockedCoins: Set<String> = []

    // Archivement data for the first shelf coin
    let firstShelfCoin = [Archivement(assetId: "2000Tasks", title: "Y2K", description: "Move 2000 tasks: ‘There is a pleasure in being mad which none but madmen know.’")]

    // Archivement data for the second shelf coins
    let secondShelfCoins: [Archivement] = [
        Archivement(assetId: "Skill4TheWin", title: "Skill for the WIN", description: "Unlock 3 skills and use them in a game"),
        Archivement(assetId: "Warden", title: "He is always watching", description: "Lose a game because of the warden.\n‘You can screw up but don't let the boss see it’."),
        Archivement(assetId: "FirstWin", title: "First game", description: "Win your first PvE game")
    ]

    // Archivement data for the third shelf coin
    let thirdShelfCoins = [Archivement(assetId: "outscoreTheCreator", title: "Better than god", description: "Outscore the game creator")]

    // Root entity added to the RealityView
    var scaledRootEntity = Entity()

    // Tracks the currently hovered coin
    var hoveredCoin: String? = nil
    
    let gameCenterHelper = GameCenterHelper()

    // Function to load unlocked achievements at the start
    func loadUnlockedAchievements() {
        GKAchievementDescription.loadAchievementDescriptions { [weak self] descriptions, error in
            guard let self = self, let descriptions = descriptions else { return }

            GKAchievement.loadAchievements { achievements, error in
                guard let achievements = achievements else { return }

                let nonHiddenAchievements = descriptions.filter { !$0.isHidden }
                
                for description in nonHiddenAchievements {
                    let identifier = description.identifier
                    
                    let isUnlocked = achievements.first(where: { $0.identifier == identifier })?.isCompleted ?? false

                    if isUnlocked {
                        self.unlockedCoins.insert(identifier)
                    } else {
                        self.lockedCoins.insert(identifier)
                    }

                    print("Achievement \(description.title) is visible to the user")
                }
            }
        }
    }


    // Creates attachments for each archivement and sets the hover effect
    func createAttachments(for archivements: [Archivement]) -> [Attachment<some View>] {
        archivements.map { archivement in
            Attachment(id: archivement.assetId) {
                VStack {
                    Text(archivement.title)
                        .font(.extraLargeTitle)
                        .padding()
                        .glassBackgroundEffect()

                    Text(archivement.description)
                        .lineLimit(3, reservesSpace: true)
                        .font(.largeTitle)
                        .padding(20)
                        .glassBackgroundEffect()
                        .frame(width: 700)
                }
                .hoverEffect { effect, isActive, proxy in
                    effect.clipShape(.capsule.size(
                        width: proxy.size.width,
                        height: isActive ? proxy.size.height : proxy.size.height * 0.36,
                        anchor: .top
                    ))
                    .scaleEffect(isActive ? 1.5 : 1.0)
                }
            }
        }
    }

    // Scales the entity based on the window zoom setting of the RealityView
    func scale(entity: Entity, content: RealityViewContent, proxy: GeometryProxy3D, defaultSize: Size3D) {
        let scaledVolumeSize = content.convert(proxy.frame(in: .local), from: .local, to: .scene)
        let scale = (scaledVolumeSize.extents / SIMD3<Float>(defaultSize)).min()
        entity.scale = .one * scale
    }

    // Disables a coin by changing its material to black and adding an aura
    private func disableCoin(coinEntity: ModelEntity, shelfEntity: ModelEntity) {
        let blackMaterial = SimpleMaterial(color: .black, isMetallic: true)
        coinEntity.model?.materials = [blackMaterial]

        let auraEntity = ModelEntity(mesh: .generateSphere(radius: 0.08))
        let auraMaterial = SimpleMaterial(color: UIColor.black.withAlphaComponent(0.5), isMetallic: false)
        auraEntity.model?.materials = [auraMaterial]
        auraEntity.position = coinEntity.position
        auraEntity.scale = SIMD3(repeating: 1.5)
        shelfEntity.addChild(auraEntity)
    }

    // Creates and positions the first shelf coin
    func createFirst(shelfEntity: ModelEntity, in content: RealityViewContent, with attachments: RealityViewAttachments) async {
        await createShelf(shelfEntity, for: firstShelfCoin, in: content, with: attachments, modelPosition: [0, 0, 1.45], modelScale: SIMD3(x: 0.1, y: 0.2, z: 0.1), attachmentYPosition: 1.25)
    }

    // Creates and positions the second shelf coins
    func createSecond(shelfEntity: ModelEntity, in content: RealityViewContent, with attachments: RealityViewAttachments) async {
        await createShelf(shelfEntity, for: secondShelfCoins, in: content, with: attachments, modelPosition: [0.5, 0, 1.05], modelScale: SIMD3(x: 0.07, y: 0.07, z: 0.08), attachmentYPosition: 0.85)
    }

    // Creates and positions the third shelf coin
    func createThird(shelfEntity: ModelEntity, in content: RealityViewContent, with attachments: RealityViewAttachments) async {
        await createShelf(shelfEntity, for: thirdShelfCoins, in: content, with: attachments, modelPosition: [0, 0, 0.7], modelScale: SIMD3(x: 0.1, y: 0.1, z: 0.1), attachmentYPosition: 0.5)
    }

    // Generic function to create shelf coins and attachments dynamically based on archivements
    @MainActor
    private func createShelf(_ shelfEntity: ModelEntity,
                             for archivements: [Archivement],
                             in content: RealityViewContent,
                             with attachments: RealityViewAttachments,
                             modelPosition: SIMD3<Float>,
                             modelScale: SIMD3<Float>? = SIMD3(x: 0.07, y: 0.07, z: 0.08),
                             attachmentYPosition: Float) async {
        // Archivements that are visible for the user (locked and unlocked)
        let availableArchivements = archivements.filter { unlockedCoins.contains($0.assetId) || lockedCoins.contains($0.assetId) }
        
        let startIndex = -(availableArchivements.count / 2)
        let endIndex = availableArchivements.count / 2

        // Iterates over archivements to create entities
        for i in startIndex...endIndex {
            let index = i + (availableArchivements.count / 2)
            if index < availableArchivements.count && index >= 0 {
                let archivement = availableArchivements[index]
                if let coinEntity = try? await ModelEntity(named: archivement.assetId) {
                    if let modelScale {
                        coinEntity.scale = modelScale
                    }
                    coinEntity.orientation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
                    var currentIterationEntityPosition = modelPosition
                    currentIterationEntityPosition.x *= Float(i)
                    coinEntity.position = currentIterationEntityPosition

                    let isArchivementLocked = lockedCoins.contains(archivement.assetId)
                    if isArchivementLocked {
                        disableCoin(coinEntity: coinEntity, shelfEntity: shelfEntity)
                    }

                    shelfEntity.addChild(coinEntity)
                    doRotation(coinEntity: coinEntity)

                    // Adds description text as an attachment
                    if let text = attachments.entity(for: archivement.assetId) {
                        let textPosition: SIMD3<Float> = [currentIterationEntityPosition.x, attachmentYPosition, 0.2]
                        text.position = textPosition
                        text.isEnabled = !isArchivementLocked
                        shelfEntity.addChild(text, preservingWorldTransform: true)
                    }
                }
            }
        }
    }

    // Rotates the entity with a timer
    func doRotation(coinEntity: ModelEntity) {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            self.rotationAngle += 0.2
            if self.rotationAngle >= 360 {
                self.rotationAngle = 0
            }
            coinEntity.transform.rotation = simd_quatf(angle: Float(self.rotationAngle) * .pi / 50, axis: [0, 0, 1])
        }
        RunLoop.current.add(timer, forMode: .common)
    }
}
