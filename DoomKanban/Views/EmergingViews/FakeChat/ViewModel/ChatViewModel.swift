//
//  ChatViewModel.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import SwiftUI

@Observable
class ChatViewModel {
    var messages: [ChatMessage] = []
    var timer: Timer?
    var chatMessageOptions: ChatMessageOptions?
}

extension ChatViewModel {
    func loadChatMessages(onCompletion: @escaping () -> Void) {
        if let url = Bundle.main.url(forResource: "FakeMobileChat", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let chatMessageOptions = try? JSONDecoder().decode(ChatMessageOptions.self, from: data) {
            self.chatMessageOptions = chatMessageOptions
            
            let allMessages = [
                ChatMessage(text: chatMessageOptions.firstMessageOptions.randomElement() ?? "", isFromCurrentUser: true),
                ChatMessage(text: chatMessageOptions.secondMessageOptions.randomElement() ?? "", isFromCurrentUser: false),
                ChatMessage(text: chatMessageOptions.thirdMessageOptions.randomElement() ?? "", isFromCurrentUser: true),
                ChatMessage(text: chatMessageOptions.forthMessageOptions.randomElement() ?? "", isFromCurrentUser: false),
                ChatMessage(text: "👍", isFromCurrentUser: true)
            ]
            
            var currentMessageIndex = 0
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                withAnimation {
                    self.messages.append(allMessages[currentMessageIndex])
                }
                currentMessageIndex += 1
                
                self.timer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 1...2), repeats: true) { timer in
                    if currentMessageIndex < allMessages.count {
                        withAnimation {
                            self.messages.append(allMessages[currentMessageIndex])
                        }
                        currentMessageIndex += 1
                    } else {
                        timer.invalidate()
                        onCompletion()  // Llamada al callback cuando termina de mostrar todos los mensajes
                    }
                }
            }
        } else {
            print("Error loading FakeMobileChat.json")
        }
    }
}
