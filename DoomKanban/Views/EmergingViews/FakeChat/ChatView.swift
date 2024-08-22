//
//  ChatView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 21/8/24.
//

import SwiftUI

struct ChatMessageOptions: Codable {
    let firstMessageOptions: [String]
    let secondMessageOptions: [String]
    let thirdMessageOptions: [String]
    let forthMessageOptions: [String]
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromCurrentUser: Bool
}

struct ChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var timer: Timer?
    @State private var chatMessageOptions: ChatMessageOptions?
    @Environment(\.mobileChatVisibility) private var isChatVisible
    
    var onComplete: (() -> Void)?  // Callback for notifying parent view when the last message has been displayed

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack {
                        ForEach(messages) { message in
                            HStack {
                                if message.isFromCurrentUser {
                                    Spacer()
                                    Text(message.text)
                                        .padding(.vertical, geometry.size.width*0.03)
                                        .padding(.horizontal, geometry.size.width*0.05)
                                        .font(.system(size: geometry.size.width*0.04))
                                        .background(Color.blue)
                                        .clipShape(RoundedRectangle(cornerRadius: geometry.size.width*0.1))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: geometry.size.width * 0.75, alignment: .trailing)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .id(message.id)
                                } else {
                                    Text(message.text)
                                        .padding(.vertical, geometry.size.width*0.03)
                                        .padding(.horizontal, geometry.size.width*0.05)
                                        .font(.system(size: geometry.size.width*0.04))
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: geometry.size.width*0.1))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: geometry.size.width * 0.75, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .id(message.id)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 1)
                        }
                    }
                        .padding(.vertical, geometry.size.height*0.05)
                        .frame(width: geometry.size.width, height: geometry.size.height*0.7)
                    .onChange(of: messages.count) {
                        withAnimation {
                            scrollViewProxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                    .onAppear {
                            messages.removeAll()
                            loadChatMessages {
                                onComplete?()
                            }
//                            DispatchQueue.main.async {
//                                withAnimation {
//                                    scrollViewProxy.scrollTo(messages.last?.id, anchor: .bottom)
//                                }
//                            }
                    }
                    .onChange(of: isChatVisible.wrappedValue.0) { oldValue, newValue in
                        if newValue == .visible {
                            // Delete and restart messages for new chat animation
                            messages.removeAll()
                            loadChatMessages {
                                onComplete?()
                            }
                            DispatchQueue.main.async {
                                withAnimation {
                                    scrollViewProxy.scrollTo(messages.last?.id, anchor: .bottom)
                                }
                            }
                        } else {
                            timer?.invalidate()
                        }
                    }
                    .onDisappear {
                        timer?.invalidate()
                    }
                }
            }
        }
    }
    
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
                    messages.append(allMessages[currentMessageIndex])
                }
                currentMessageIndex += 1
                
                timer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 2...4), repeats: true) { timer in
                    if currentMessageIndex < allMessages.count {
                        withAnimation {
                            messages.append(allMessages[currentMessageIndex])
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
