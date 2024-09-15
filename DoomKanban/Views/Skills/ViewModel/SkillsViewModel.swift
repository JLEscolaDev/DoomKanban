//
//  SkillsViewModel.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import SwiftUI

@Observable
class SkillsViewModel {
    internal init(skills: [Skill] = [], orientation: Orientation = .horizontal, counter: Int = 0) {
        self.skills = skills
        self.orientation = orientation
        self.counter = counter
    }
    
    let skills: [Skill]
    var orientation: Orientation
    var counter: Int
}

