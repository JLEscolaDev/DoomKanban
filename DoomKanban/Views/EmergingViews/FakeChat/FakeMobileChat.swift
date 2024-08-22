//
//  FakeMobileChat.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 20/8/24.
//

import SwiftUI

struct FakeMobileChat: View {
    @Environment(\.mobileChatVisibility) private var isChatVisible
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
//                        .fill(.blue.opacity(0.4))
                        .frame(width: chatWidth, height: chatHeight)
                        .overlay {
                            ChatView() {
                                onComplete?()
                            }
//                            .background(.red)
                                .frame(width: chatWidth, height: chatHeight)
                                .allowsHitTesting(false)
//                                .background(.red)
//                            .padding(.leading, geometry.size.width * 0.1) // Ajustar para alinear más a la izquierda si es necesario
//                            .padding(.trailing, geometry.size.width * 0.04) // Ajustar para no cortar el texto si es necesario
                        }
                        .padding(.top, topPadding)
                        .padding(.leading, leadingPadding)
                }
            }.gesture(
                TapGesture()
                    .onEnded {
                        isChatVisible.wrappedValue = (.hidden, nil)
                    }
            )
    }
}

#Preview {
    FakeMobileChat().frame(width: 150, height: 300)
}
