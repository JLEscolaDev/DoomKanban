//
//  ExtrudedPointCounterTextView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 21/8/24.
//  Reference: https://forums.developer.apple.com/forums/thread/757091
//
import SwiftUI
import RealityKit
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


//import SwiftUI
//import RealityKit
//import Observation
//
//@Observable
//class PointCountingViewModel {
//    var contentEntity = Entity()
//
//       func setupContentEntity() -> Entity {
//           // Asegura que la entidad tenga un componente de colisión
//           let collisionBox = ShapeResource.generateBox(size: [1, 1, 0.1])
//           contentEntity.components[CollisionComponent.self] = CollisionComponent(shapes: [collisionBox])
//           return contentEntity
//    }
//
//    func updateText(text: String) {
//        contentEntity.children.removeAll()
//        
//        let textMeshResource: MeshResource = .generateText(text,
//                                                           extrusionDepth: 0.05,
//                                                           font: .systemFont(ofSize: 0.3),
//                                                           containerFrame: .zero,
//                                                           alignment: .center,
//                                                           lineBreakMode: .byWordWrapping)
//
//        let material = SimpleMaterial(color: .red, roughness: 1.5, isMetallic: true)
//
//        let textEntity = ModelEntity(mesh: textMeshResource, materials: [material])
//        textEntity.position = SIMD3(x: -(textMeshResource.bounds.extents.x)-0.2, y: 0.3, z: -2)
//
//        // Añadir un componente de colisión para que el texto responda a toques
//        let collisionShape = ShapeResource.generateBox(size: textMeshResource.bounds.extents)
//        textEntity.components[CollisionComponent.self] = CollisionComponent(shapes: [collisionShape])
//
//        // Registra la entidad para recibir eventos de entrada
//        textEntity.components.set(InputTargetComponent())
//
//        contentEntity.addChild(textEntity)
//    }
//
//    func moveEntity(by translation: SIMD3<Float>) {
//        contentEntity.position += translation
//    }
//}
//
//struct ExtrudedPointCounterImmersiveView: View {
//    @State private var viewModel: PointCountingViewModel = PointCountingViewModel()
//    @Environment(\.pointsCounter) private var points
//    
//    private var dragGesture: some Gesture {
//        DragGesture()
//            .onChanged { value in
//                print("x:\(Float(value.translation3D.x)), y:\(Float(value.translation3D.y)), z:\(Float(value.translation3D.z))")
//                let translation = SIMD3<Float>(0, Float(value.location3D.y) * 0.00005, 0) // Incrementa la escala para Z
//                viewModel.moveEntity(by: translation)
//                viewModel.contentEntity.position = value.convert(value.location3D, from: .local, to: viewModel.contentEntity.modelEntity.parent!)
//            }
//    }
//    
//    var body: some View {
//        RealityView { content in
//            content.add(viewModel.setupContentEntity())
//            viewModel.updateText(text: "\(points.wrappedValue)")
//        }
//        .gesture{
//            DragGesture()
//            .targetedToEntity(viewModel.contentEntity)
//                 }
//        .onChange(of: points.wrappedValue) {
//            viewModel.updateText(text: "\(points.wrappedValue)")
//        }
//    }
//}

struct ExtrudedPointCounterImmersiveView: View {
    @State var contentEntity = Entity()
    var points: Int
//    @Environment(\.pointsCounter) private var points
    
    func setupContentEntity() -> Entity {
        // Asegura que la entidad tenga un componente de colisión
        let collisionBox = ShapeResource.generateBox(size: [1, 1, 0.1])
        contentEntity.components[CollisionComponent.self] = CollisionComponent(shapes: [collisionBox])
        return contentEntity
    }
    
    func updateText(text: String) {
        contentEntity.children.removeAll()
        
        let textMeshResource: MeshResource = .generateText(text,
                                                           extrusionDepth: 0.05,
                                                           font: .systemFont(ofSize: 0.3),
                                                           containerFrame: .zero,
                                                           alignment: .left,
                                                           lineBreakMode: .byWordWrapping)

        let material = SimpleMaterial(color: .red, roughness: 1.5, isMetallic: true)

        let textEntity = ModelEntity(mesh: textMeshResource, materials: [material])
//        textEntity.position = [-0.4,-0.45,0.5]
        textEntity.position = [-0.8,-0.18,0]
//        textEntity.position = SIMD3(x: -(textMeshResource.bounds.extents.x)-0.2, y: 0.3, z: -2)

        // Añadir un componente de colisión para que el texto responda a toques
        let collisionShape = ShapeResource.generateBox(size: textMeshResource.bounds.extents)
        textEntity.components[CollisionComponent.self] = CollisionComponent(shapes: [collisionShape])

        // Registra la entidad para recibir eventos de entrada
        textEntity.components.set(InputTargetComponent())

        contentEntity.addChild(textEntity)
    }
    
    var body: some View {
        RealityView { content in
            let model = setupContentEntity()
                contentEntity = model
                content.add(model)
            updateText(text: "\(points)")
        }.gesture(
            DragGesture()
                .targetedToEntity(
                    contentEntity
                )
                .onChanged(
                    { value in
                        print(value.location3D*0.0001)
                        contentEntity.position = value
                            .convert(
                                value.location3D,
                                from: .local,
                                to: contentEntity.parent!
                            )
                    })
        ).onChange(of: points) {
            updateText(text: "\(points)")
        }
    }
}
