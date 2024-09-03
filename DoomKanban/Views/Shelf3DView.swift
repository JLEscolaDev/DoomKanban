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

struct test: View {
    var body: some View {
        Model3D(named: "FirstMedal") { model in
                        model
                            .resizable()
                            .aspectRatio(contentMode:.fit)
                            .frame(width: 380)
                    } placeholder: {
                        ProgressView()
                    }
        
    }
}

#Preview {
    test()
}



import SwiftUI
import RealityKit

struct Shelf3DView: View {
    @Environment(\.openWindow) private var openWindow
    @State private var rotationAngle: Double = 0.0
    let coinNames: [String] = ["Skill4TheWin", "Warden", "FirstWin"]
    
    // The value passed to the volumetric window group's
    // `defaultSize(_:in:)` view modifier.
    let defaultSize: Size3D
    // A root entity added to the `RealityView`.
    //
    // This entity is automatically scaled to reflect changes
    // to the user's Window Zoom setting.
    //
    // All other entities in the volume should be added as
    // children of this view instead of being added to the
    // `RealityViewContent` object directly.
    @State private var scaledRootEntity = Entity()
    
    var body: some View {
            GeometryReader3D { proxy in
                RealityView { content in
                    content.add(scaledRootEntity)
                    
                    scale(entity: scaledRootEntity, content: content, proxy: proxy, defaultSize: defaultSize)
                    
                    if let shelfEntity = try? await ModelEntity(named: "Round Book Shelf") {
                        // Ajustar la escala y aplicar las físicas
                        shelfEntity.scale = [1.0, 1.0, 1.0]
                        shelfEntity.transform.translation.y = 0 // Ajustar posición inicial

                        // Agregar física dinámica a la estantería
                        let shelfShape = ShapeResource.generateBox(size: [1.0, 1.0, 0.5])
                        shelfEntity.physicsBody = PhysicsBodyComponent(shapes: [shelfShape], mass: 8.0, material: .generate(friction: 0.8, restitution: 0.1), mode: .dynamic)
                        shelfEntity.collision = CollisionComponent(shapes: [shelfShape])

                        scaledRootEntity.addChild(shelfEntity)
                        
                        await createLockedCoin(shelfEntity: shelfEntity)
                        await createSecond(shelfEntity: shelfEntity)
                        await createThird(shelfEntity: shelfEntity)
                    }

                    // Crear el suelo con físicas estáticas usando un box muy delgado
                    let floorEntity = ModelEntity(mesh: .generateBox(size: [0.01, 0.01, 0.01])) // Genera un box delgado para simular un plano
                    floorEntity.model?.materials = [SimpleMaterial(color: .black, isMetallic: true)]
                    let floorShape = ShapeResource.generateBox(size: [2, 0.01, 2])
                    floorEntity.physicsBody = PhysicsBodyComponent(shapes: [floorShape], density: 10, mode: .static)
                    floorEntity.collision = CollisionComponent(shapes: [floorShape])
                    floorEntity.position = [0, -1.25, 0] // Ajustar la altura del suelo
                    scaledRootEntity.addChild(floorEntity)
                    
                } update: { content in
                    scale(entity: scaledRootEntity, content: content, proxy: proxy, defaultSize: defaultSize)
                }
            }.toolbar {
                ToolbarItem(placement: .bottomOrnament) {
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
    
    // Scales `entity` to match the current Window Zoom scale.
    func scale(entity: Entity, content: RealityViewContent,
               proxy: GeometryProxy3D, defaultSize: Size3D) {
        // The size of the volume, scaled to reflect the
        // selected Window Zoom.
        let scaledVolumeSize = content.convert(
            proxy.frame(in: .local), from: .local, to: .scene)

        // The user's selected Window Zoom scale factor, as
        // a ratio between the displayed size of the volume and
        // the default size of the volume's window group.
        let scale = (scaledVolumeSize.extents/SIMD3<Float>(defaultSize)).min()

        entity.scale = .one*scale
    }
    
    // Función reusable para deshabilitar una moneda
    private func disableCoin(coinEntity: ModelEntity, shelfEntity: ModelEntity) {
        // Crear un material negro para indicar que la moneda está bloqueada
        let blackMaterial = SimpleMaterial(color: .black, isMetallic: true)
        coinEntity.model?.materials = [blackMaterial]
        
        // Crear una entidad adicional para el aura
        let auraEntity = ModelEntity(mesh: .generateSphere(radius: 0.08))
        let auraMaterial = SimpleMaterial(color: UIColor.black.withAlphaComponent(0.5), isMetallic: false)
        auraEntity.model?.materials = [auraMaterial]
        
        // Posicionar el aura alrededor de la moneda
        auraEntity.position = coinEntity.position
        auraEntity.scale = SIMD3(repeating: 1.5) // Ajustar el tamaño del aura
        shelfEntity.addChild(auraEntity)
    }
    
    private func createLockedCoin(shelfEntity: ModelEntity) async -> ModelEntity? {
        if let coinEntity = try? await ModelEntity(named: "2000Tasks") {
            coinEntity.scale = SIMD3(x: 0.1, y: 0.2, z: 0.1)
            coinEntity.orientation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
            coinEntity.position = [0, 0, 1.45]
            
            // Deshabilitar la moneda usando la función reusable
            disableCoin(coinEntity: coinEntity, shelfEntity: shelfEntity)
            
            shelfEntity.addChild(coinEntity)
            doRotation(coinEntity: coinEntity)
        }
        return nil
    }
    
    private func createSecond(shelfEntity: ModelEntity) async -> ModelEntity? {
        let startIndex = -(coinNames.count / 2)
        let endIndex = coinNames.count / 2
        
        for i in startIndex...endIndex {
            let index = i + (coinNames.count / 2)
            if index < coinNames.count && index >= 0 {
                let coinName = coinNames[index]
                if let coinEntity = try? await ModelEntity(named: coinName) {
                    coinEntity.scale = SIMD3(x: 0.07, y: 0.07, z: 0.08)
                    coinEntity.orientation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
                    coinEntity.position = [Float(i) * 0.5, 0, 1.05]
                    shelfEntity.addChild(coinEntity)
                    doRotation(coinEntity: coinEntity)
                }
            }
        }
        return nil
    }
    
    private func createThird(shelfEntity: ModelEntity) async -> ModelEntity? {
        if let coinEntity = try? await ModelEntity(named: "GenericMedal") {
            coinEntity.scale = SIMD3(x: 0.1, y: 0.1, z: 0.1)
            coinEntity.orientation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
            coinEntity.position = [0, 0, 0.7]
            shelfEntity.addChild(coinEntity)
            doRotation(coinEntity: coinEntity)
        }
        return nil
    }
    
    func doRotation(coinEntity: ModelEntity) {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            rotationAngle += 0.2
            if rotationAngle >= 360 {
                rotationAngle = 0
            }
            coinEntity.transform.rotation = simd_quatf(angle: Float(rotationAngle) * .pi / 50, axis: [0, 0, 1])
        }
        RunLoop.current.add(timer, forMode: .common)
    }
}

#Preview(windowStyle: .volumetric) {
    let defaultSize = Size3D(width: 2, height: 2, depth: 2)
    Shelf3DView(defaultSize: defaultSize)
}


//  Desglose de tareas:
//
//    skills [PENDIENTE DE DEFINIR]
//
//    Estados Card: flag, exclamation y complete.
    //    - complete: añadir temporizador (no sé si al padre o al hijo) y cuando acaba debe actualizarse el estado de la vista (con un binding? o debería ser la vista quien dispare el temporizador random definido con un tiempo por el padre?) El temporizador debe hacer algo en el padre? o sólo actualizar la tarea?
    //
    //    - Exclamation:
        //     PENDIENTE: Generación automática de tareas con este parámetro randomizado.
        //     PENDIENTE: Da el doble de puntos.


    //    - Flag: Si la tarea tiene una flag se debe entrar a la pantalla del chat para poder completarse y avanzar a la siguiente columna. La tarea con flag no puede completarse ni moverse (tengo que deshabilitar el valid drop)
            //PENDIENTE: mover el openWindow del kanbanLayout al KanbanBoard
            //PENDIENTE: Debería dar puntos solucionar el flag? yo diría que sí. Cuando se soluciona el flag la tarea pasa automáticamente a complete (ES IMPORTANTE NO USAR UN TOGGLE PARA NO TENER UN DATA RACE SI LA TAREA SE COMPLETASE A POSTERIORI Y SE HICIERA EL TOGGLE DOS VECES)
            //OPTATIVO: Intentar dar profundidad al móvil


// PENDIENTE: Crear contador aleatorio para activar y desactivar el ojo del supervisor en el kanbanBoard

// PENDIENTE: Crear texto 3d GAME OVER cuando tienes 3 warnings del mismo tipo.

// OPCIONAL: Añadir partículas de explosión cuando un warning aparece y las cards se eliminan
// OPCIONAL: Añadir brillo al cambiar el contador de puntos
