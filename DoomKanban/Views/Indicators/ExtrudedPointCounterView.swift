//
//  ExtrudedPointCounterTextView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 21/8/24.
//
//import SwiftUI
//import RealityKit
//
//struct ExtrudedPointCounterView: View {
//
//    @State var showImmersiveSpace = false
//
//    @Environment(\.openImmersiveSpace) var openImmersiveSpace
//    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
//
//    var body: some View {
//        NavigationStack {
//            Toggle("Show ImmersiveSpace", isOn: $showImmersiveSpace)
//                .toggleStyle(.button)
//        }
//        .onChange(of: showImmersiveSpace) { _, newValue in
//            Task {
//                if newValue {
//                    await openImmersiveSpace(id: "ImmersiveSpace")
//                } else {
//                    await dismissImmersiveSpace()
//                }
//            }
//        }
//    }
//}


import RealityKit
import Observation


import SwiftUI
import RealityKit
import Observation

@Observable
class PointCountingViewModel {
    private var contentEntity = Entity()

    func setupContentEntity() -> Entity {
        return contentEntity
    }

    func updateText(text: String) {
        contentEntity.children.removeAll()
        let textMeshResource: MeshResource = .generateText(text,
                                                           extrusionDepth: 0.05,
                                                           font: .systemFont(ofSize: 0.3),
                                                           containerFrame: .zero,
                                                           alignment: .center,
                                                           lineBreakMode: .byWordWrapping)

        let material = SimpleMaterial(color: .red, roughness: 1.5, isMetallic: true)

        let textEntity = ModelEntity(mesh: textMeshResource, materials: [material])
        textEntity.position = SIMD3(x: -(textMeshResource.bounds.extents.x)-0.2, y: 0.1, z: -2)

        contentEntity.addChild(textEntity)
    }
}

struct ExtrudedPointCounterImmersiveView: View {
    @State private var viewModel: PointCountingViewModel = PointCountingViewModel()
    @Environment(\.pointsCounter) private var points

    var body: some View {
        RealityView { content in
            content.add(viewModel.setupContentEntity())
            viewModel.updateText(text: "\(points.wrappedValue)")
        }
        .onChange(of: points.wrappedValue) {
            viewModel.updateText(text: "\(points.wrappedValue)")
        }
    }
}
