//
//  RunningSprintVM.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 12/9/24.
//

import SwiftUI

@Observable
class RunningSprintVM {
    init(sprint: KanbanSprint, leftColor: Color? = nil, rightColor: Color? = nil, customRemainingTasksCount: Int? = nil) {
        self.sprint = sprint
        self.leftColor = leftColor ?? sprint.projectColor
        self.rightColor = rightColor
        self.customRemainingTasksCount = customRemainingTasksCount
    }
    
    let sprint: KanbanSprint
    let customRemainingTasksCount: Int?
    let leftColor: Color
    let rightColor: Color?

    /// We control the appearence of the indicator based on if it is going to be the last one or not.
    /// (We use a rectangle to notify the user the sprint is finishing)
    var isNextSprintTaskTheLastOne: Bool {
        (customRemainingTasksCount ?? sprint.tasks.count)  == 1
    }
}
