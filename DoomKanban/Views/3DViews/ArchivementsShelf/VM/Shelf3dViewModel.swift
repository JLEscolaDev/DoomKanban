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

    // Dynamically loaded unlocked and locked achievements from Game Center
    var unlockedCoins: Set<String> = []
    var lockedCoins: Set<String> = []

    // New dictionaries to store unlocked and locked achievements
    var unlockedAchievements: [String: GKAchievementDescription] = [:]
    var lockedAchievements: [String: GKAchievementDescription] = [:]

    // Achievement IDs for the shelves (maintaining only the IDs)
    let firstShelfCoinIDs = ["2000Tasks"]
    let secondShelfCoinIDs = ["Skill4TheWin", "Warden", "FirstWin"]
    let thirdShelfCoinIDs = ["outscoreTheCreator"]

    // Root entity added to the RealityView
    var scaledRootEntity = Entity()

    // Tracks the currently hovered coin
    var hoveredCoin: String? = nil
    
    // Cache to avoid multiple authentication attempts
//    var isAuthenticated = false

    var gameCenterHelper = GameCenterHelper.shared

    // Function to load unlocked achievements at the start
    func loadUnlockedAchievements() {
        GKAchievementDescription.loadAchievementDescriptions { [weak self] descriptions, error in
            guard let self = self, let descriptions = descriptions else { return }

            // Filter all achievements that are not hidden
            let nonHiddenAchievements = descriptions.filter { !$0.isHidden }

            GKAchievement.loadAchievements { achievements, error in
                guard let achievements = achievements else { return }

                // Iterate over all visible (non-hidden) achievements
                for description in nonHiddenAchievements {
                    let identifier = description.identifier
                    
                    // Check if the achievement is unlocked
                    let isUnlocked = achievements.first(where: { $0.identifier == identifier })?.isCompleted ?? false

                    if isUnlocked {
                        // Add unlocked achievement to unlockedCoins set and unlockedAchievements dictionary
                        self.unlockedCoins.insert(identifier)
                        self.unlockedAchievements[identifier] = description
                    } else {
                        // Add locked achievement to lockedCoins set and lockedAchievements dictionary
                        self.lockedCoins.insert(identifier)
                        self.lockedAchievements[identifier] = description
                    }
                }
            }
        }
    }

    // Creates attachments for each achievement and sets the hover effect
    func createAttachments(for achievementIDs: [String]) -> [Attachment<some View>] {
        achievementIDs.map { assetId in
            Attachment(id: assetId) {
                // Check if the achievement is unlocked
                let isUnlocked = self.unlockedCoins.contains(assetId)
                
                // Retrieve the achievement description based on whether it's unlocked or locked
                let achievementDescription = isUnlocked
                ? self.unlockedAchievements[assetId]?.achievedDescription
                : self.lockedAchievements[assetId]?.unachievedDescription
                
                let achievementTitle = isUnlocked
                ? self.unlockedAchievements[assetId]?.title
                : "*********"

                VStack {
                    Text(achievementTitle ?? "Unknown Title")
                        .font(.extraLargeTitle)
                        .padding()
                        .glassBackgroundEffect()

                    Text(achievementDescription ?? "No description available")
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
        await createShelf(shelfEntity, for: firstShelfCoinIDs, in: content, with: attachments, modelPosition: [0, 0, 1.45], modelScale: SIMD3(x: 0.1, y: 0.2, z: 0.1), attachmentYPosition: 1.25)
    }

    // Creates and positions the second shelf coins
    func createSecond(shelfEntity: ModelEntity, in content: RealityViewContent, with attachments: RealityViewAttachments) async {
        await createShelf(shelfEntity, for: secondShelfCoinIDs, in: content, with: attachments, modelPosition: [0.5, 0, 1.05], modelScale: SIMD3(x: 0.07, y: 0.07, z: 0.08), attachmentYPosition: 0.85)
    }

    // Creates and positions the third shelf coin
    func createThird(shelfEntity: ModelEntity, in content: RealityViewContent, with attachments: RealityViewAttachments) async {
        await createShelf(shelfEntity, for: thirdShelfCoinIDs, in: content, with: attachments, modelPosition: [0, 0, 0.7], modelScale: SIMD3(x: 0.1, y: 0.1, z: 0.1), attachmentYPosition: 0.5)
    }

    // Generic function to create shelf coins and attachments dynamically based on achievements
    @MainActor
    private func createShelf(_ shelfEntity: ModelEntity,
                             for achievementIDs: [String],
                             in content: RealityViewContent,
                             with attachments: RealityViewAttachments,
                             modelPosition: SIMD3<Float>,
                             modelScale: SIMD3<Float>? = SIMD3(x: 0.07, y: 0.07, z: 0.08),
                             attachmentYPosition: Float) async {
        
        let availableAchievements = achievementIDs.filter { unlockedCoins.contains($0) || lockedCoins.contains($0) }

        let startIndex = -(availableAchievements.count / 2)
        let endIndex = availableAchievements.count / 2

        // Iterates over achievements to create entities
        for i in startIndex...endIndex {
            let index = i + (availableAchievements.count / 2)
            if index < availableAchievements.count && index >= 0 {
                let achievementID = availableAchievements[index]
                if let coinEntity = try? await ModelEntity(named: achievementID) {
                    if let modelScale {
                        coinEntity.scale = modelScale
                    }
                    coinEntity.orientation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
                    var currentIterationEntityPosition = modelPosition
                    currentIterationEntityPosition.x *= Float(i)
                    coinEntity.position = currentIterationEntityPosition

                    let isAchievementLocked = lockedCoins.contains(achievementID)
                    if isAchievementLocked {
                        disableCoin(coinEntity: coinEntity, shelfEntity: shelfEntity)
                    }

                    shelfEntity.addChild(coinEntity)
                    doRotation(coinEntity: coinEntity)

                    // Adds description text as an attachment
                    if let text = attachments.entity(for: achievementID) {
                        let textPosition: SIMD3<Float> = [currentIterationEntityPosition.x, attachmentYPosition, 0.2]
                        text.position = textPosition
//                        text.isEnabled = !isAchievementLocked
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
