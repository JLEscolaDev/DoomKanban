//
//  ChatMessage.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//
import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromCurrentUser: Bool
}
