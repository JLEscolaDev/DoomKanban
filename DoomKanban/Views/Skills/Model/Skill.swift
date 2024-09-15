//
//  Skill.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import SwiftUI

struct Skill: Identifiable {
    let id = UUID()
    let icon: Image
    let coolDown: Int
    let type: SkillType
}
