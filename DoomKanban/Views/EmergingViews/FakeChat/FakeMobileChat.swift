//
//  FakeMobileChat.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 20/8/24.
//

import SwiftUI

struct FakeMobileChat: View {
    @Environment(KanbanAppVM.self) var kanbanVM
    var onComplete: (() -> Void)?  // Callback for notifying parent view when the last message has been displayed
    
    var body: some View {
        Image(.fakeChatEmojiKeyboard)
            .resizable()
            .scaledToFit()
            .overlay {
                GeometryReader { geometry in
                    let chatWidth = geometry.size.width*0.82
                    let chatHeight = geometry.size.height*0.35
                    let leadingPadding = (geometry.size.width - chatWidth)/2
                    let topPadding = geometry.size.height*0.16
                    Rectangle()
                        .frame(width: chatWidth, height: chatHeight)
                        .overlay {
                            ChatView() {
                                onComplete?()
                                kanbanVM.chatVisibility.0 = .hidden
                            }
                                .frame(width: chatWidth, height: chatHeight)
                                .allowsHitTesting(false)
                        }
                        .padding(.top, topPadding)
                        .padding(.leading, leadingPadding)
                }
            }
    }
}

#Preview {
    FakeMobileChat().frame(width: 150, height: 300)
}

//import SwiftUI
//import RealityKit
//
//struct FakeMobileChat: View {
//    @Environment(KanbanAppVM.self) var kanbanVM
//    var onComplete: (() -> Void)?  // Callback for notifying parent view when the last message has been displayed
//    
//    var body: some View {
//        ZStack {
//            RealityView { content in
//                let blackMaterial = SimpleMaterial(color: .black, isMetallic: true)
//                let box = ModelEntity(mesh: .generateBox(size: .init(x: 0.145, y: 0.29, z: 0.03), cornerRadius: 0.1), materials: [blackMaterial])
//                
//                box.position = [0, 0, 0.352]
//                // Create the entity for the phone
//                        content.add(box)
//                    }
//            .frame(width: 200, height: 400) // Make sure it has enough space
//            .clipShape(RoundedRectangle(cornerRadius: 20))
//            Image(.fakeChatEmojiKeyboard)
//                .resizable()
//                .scaledToFit()
//                .overlay {
//                    GeometryReader { geometry in
//                        let chatWidth = geometry.size.width*0.82
//                        let chatHeight = geometry.size.height*0.35
//                        let leadingPadding = (geometry.size.width - chatWidth)/2
//                        let topPadding = geometry.size.height*0.16
//                        Rectangle()
//                            .frame(width: chatWidth, height: chatHeight)
//                            .overlay {
//                                ChatView() {
//                                    onComplete?()
//                                    kanbanVM.chatVisibility.0 = .hidden
//                                }
//                                .frame(width: chatWidth, height: chatHeight)
//                                .allowsHitTesting(false)
//                            }
//                            .padding(.top, topPadding)
//                            .padding(.leading, leadingPadding)
//                    }
//                }
//        }
//    }
//    func createPhoneEntity() -> Entity {
//            // Phone dimensions
//            let phoneWidth: Float = 0.2
//            let phoneHeight: Float = 0.4
//            let phoneDepth: Float = 0.02
//
//            // Create a rounded rectangular mesh for the phone body
//            let phoneMesh = MeshResource.generateBox(size: [phoneWidth, phoneHeight, phoneDepth], cornerRadius: 0.02)
//
//            // Create a black unlit material for the phone body
//            let blackMaterial = SimpleMaterial(color: .black, isMetallic: true)
//            
//            // Create the entity for the phone
//            let phoneEntity = ModelEntity(mesh: phoneMesh, materials: [blackMaterial])
//
//            // Position the phone slightly in front of the camera
//            phoneEntity.position = [0, 0, -0.5]
//
//            return phoneEntity
//        }
//}
