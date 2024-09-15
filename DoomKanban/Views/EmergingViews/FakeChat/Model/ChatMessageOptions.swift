//
//  ChatMessageOptions.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//
import Foundation

struct ChatMessageOptions: Codable {
    let firstMessageOptions: [String]
    let secondMessageOptions: [String]
    let thirdMessageOptions: [String]
    let forthMessageOptions: [String]
}
