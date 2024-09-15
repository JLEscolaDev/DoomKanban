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
            .overlay(emojiKeyboardOverlay)
    }
    
    private var emojiKeyboardOverlay: some View {
        GeometryReader { geometry in
            let chatWidth = geometry.size.width * 0.82
            let chatHeight = geometry.size.height * 0.35
            let leadingPadding = (geometry.size.width - chatWidth) / 2
            let topPadding = geometry.size.height * 0.16
            
            Rectangle()
                .frame(width: chatWidth, height: chatHeight)
                .overlay(chatViewOverlay(chatWidth: chatWidth, chatHeight: chatHeight))
                .padding(.top, topPadding)
                .padding(.leading, leadingPadding)
        }
    }
    
    private func chatViewOverlay(chatWidth: CGFloat, chatHeight: CGFloat) -> some View {
        ChatView() {
            onComplete?()
            kanbanVM.chatVisibility.0 = .hidden
        }
        .frame(width: chatWidth, height: chatHeight)
        .allowsHitTesting(false)
    }
}

#Preview {
    FakeMobileChat().frame(width: 150, height: 300)
}
