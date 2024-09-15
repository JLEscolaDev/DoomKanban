//
//  KanbanAppVM.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import SwiftUI

@Observable
class KanbanAppVM {
    init() {
        self.sprints = []
        self.originalTasks = []
        self.mixedTasks = []
        toDoTasks = []
        inProgressTasks = []
        testingTasks = []
        doneTasks = []
        startNewRound()
        startWardenMonitoring()
    }

    var points = 0
    
    var round: Int = 0
    let roundAdvanceModifier: CGFloat = 0.25
    
    var wardenIsWatching: Bool = false
    var chatVisibility: (Visibility, KanbanTask?) = (.hidden, nil)
    var warningList: [WarningsInfo] = []

    // --- Kanban Content -----
    var sprints: [KanbanSprint]
    @ObservationIgnored var originalTasks: [KanbanTask]
    var mixedTasks: [KanbanTask]
    
    @ObservationIgnored var draggedCard: KanbanTask?
    var toDoTasks: [KanbanTask]
    var inProgressTasks: [KanbanTask]
    var testingTasks: [KanbanTask]
    var doneTasks: [KanbanTask]
    // ------------------------ //

    
    // --- Task drop animation
    var nextTaskAnimationTime: CGFloat {
        return max(0.25, 2 - (roundAdvanceModifier / 2) * CGFloat(round))
    }
    var counter: CGFloat {
        return max(1, 3 - roundAdvanceModifier * CGFloat(round))
    }
    // ----------------------- //
    
    
    // --- Skills management
    var showNextTaskCounterView: Bool = false // Skill chronoMaster
    var tasksAutocompletesFaster: Bool = false // Skill devFlowProblemsTow
    var removeAllTasksFromSelectedProject: Bool = false // Skill companyExpert
    // ----------------------- //
}

extension KanbanAppVM: Equatable {
    static func == (lhs: KanbanAppVM, rhs: KanbanAppVM) -> Bool {
        return lhs.sprints == rhs.sprints && lhs.mixedTasks == rhs.mixedTasks
    }
}
