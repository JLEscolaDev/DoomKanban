//
//  ExtrudedPointCounterTextView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 21/8/24.
//  Reference: https://forums.developer.apple.com/forums/thread/757091
//
import SwiftUI
import RealityKit

struct ExtrudedPointCounterImmersiveView: View {
    @State var contentEntity = Entity()
    var points: Int
    
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
        textEntity.position = [-0.8,-0.18,0]

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
