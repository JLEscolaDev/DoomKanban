//
//  ImmersiveSpaceViewModel.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import SwiftUI
import RealityFoundation

@Observable
class ImmersiveSpaceViewModel {
    var fireEntities: [Entity?] = [nil, nil, nil] // Prepare for 3 fire entities
    var smokeEntities: [Entity?] = [nil, nil, nil] // Prepare for 3 smoke entities
    var visionProPose = VisionProPose()
    var userPosition: SIMD3<Float> = [0, 0, 0]
}
