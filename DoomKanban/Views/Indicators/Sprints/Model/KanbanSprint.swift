//
//  Untitled.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 12/9/24.
//

import SwiftUI

struct KanbanSprint: Equatable {
    var id: String {
        "\(project)-\(sprintNum)"
    }
    let project: Int
    let projectColor: Color
    let sprintNum: Int
    var tasks: [KanbanTask]
}
