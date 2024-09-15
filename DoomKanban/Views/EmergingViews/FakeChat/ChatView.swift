//
//  ChatView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 21/8/24.
//

import SwiftUI

struct ChatView: View {
    @Environment(KanbanAppVM.self) var kanbanVM
    @State private var vm = ChatViewModel()
    
    var onComplete: (() -> Void)?

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack {
                        chatMessagesView(geometry: geometry)
                    }
                    .padding(.vertical, geometry.size.height * 0.05)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.7)
                    .onChange(of: vm.messages.count) {
                        handleMessagesChange(scrollViewProxy: scrollViewProxy)
                    }
                    .onAppear {
                        handleOnAppear(scrollViewProxy: scrollViewProxy)
                    }
                    .onChange(of: kanbanVM.chatVisibility.0) { _, visibility in
                        handleChatVisibilityChange(visibility: visibility, scrollViewProxy: scrollViewProxy)
                    }
                    .onDisappear {
                        handleOnDisappear()
                    }
                }
            }
        }
    }
}


// - MARK: Subviews
extension ChatView {
    /// Display the chat messages in a list
    private func chatMessagesView(geometry: GeometryProxy) -> some View {
        ForEach(vm.messages) { message in
            HStack {
                if message.isFromCurrentUser {
                    Spacer()
                    chatBubble(message.text, isCurrentUser: true, geometry: geometry)
                        .id(message.id)
                } else {
                    chatBubble(message.text, isCurrentUser: false, geometry: geometry)
                        .id(message.id)
                    Spacer()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 1)
        }
    }

    /// Chat bubble for each message
    private func chatBubble(_ text: String, isCurrentUser: Bool, geometry: GeometryProxy) -> some View {
        Text(text)
            .padding(.vertical, geometry.size.width * 0.03)
            .padding(.horizontal, geometry.size.width * 0.05)
            .font(.system(size: geometry.size.width * 0.04))
            .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: geometry.size.width * 0.1))
            .foregroundColor(isCurrentUser ? .white : .black)
            .frame(maxWidth: geometry.size.width * 0.75, alignment: isCurrentUser ? .trailing : .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// Handle scrolling when new messages arrive
    private func handleMessagesChange(scrollViewProxy: ScrollViewProxy) {
        withAnimation {
            scrollViewProxy.scrollTo(vm.messages.last?.id, anchor: .bottom)
        }
    }

    /// Handle view appearance
    private func handleOnAppear(scrollViewProxy: ScrollViewProxy) {
        vm.messages.removeAll()
        DispatchQueue.main.async {
            withAnimation {
                scrollViewProxy.scrollTo(vm.messages.last?.id, anchor: .bottom)
            }
        }
    }

    /// Handle chat visibility changes
    private func handleChatVisibilityChange(visibility: Visibility, scrollViewProxy: ScrollViewProxy) {
        if visibility == .visible {
            vm.messages.removeAll()
            vm.loadChatMessages {
                onComplete?()
            }
            DispatchQueue.main.async {
                withAnimation {
                    scrollViewProxy.scrollTo(vm.messages.last?.id, anchor: .bottom)
                }
            }
        } else {
            vm.timer?.invalidate()
        }
    }

    /// Handle view disappearance
    private func handleOnDisappear() {
        vm.timer?.invalidate()
    }
}
