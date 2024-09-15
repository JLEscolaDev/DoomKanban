//
//  because.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import SwiftUI

// ⚠️ This KanbanTask must be an @Observable class because as a simple struct it is not possible to auto-refresh the subviews hierarchy when a KanbanTask property changes
@Observable
class KanbanTask: Identifiable {
    let id: UUID
    var projectId: Int
    var sprintId: Int
    let title: String
    var color: Color
    var value: Int
    let isWarningEnabled: Bool
    var isFlagged: Bool
    var isComplete: Bool
    
    init(
        projectId: Int,
        sprintId: Int,
        title: String,
        color: Color,
        value: Int,
        isWarningEnabled: Bool = false,
        isFlagged: Bool = false,
        isComplete: Bool = false
    ) {
        self.id = UUID()
        self.projectId = projectId
        self.sprintId = sprintId
        self.title = title
        self.color = color
        self.value = value
        self.isWarningEnabled = isWarningEnabled
        self.isFlagged = isFlagged
        self.isComplete = isComplete
    }
}

extension KanbanTask: Equatable {
    static func == (lhs: KanbanTask, rhs: KanbanTask) -> Bool {
        lhs.id == rhs.id &&
        lhs.projectId == rhs.projectId &&
        lhs.sprintId == rhs.sprintId &&
        lhs.title == rhs.title &&
        lhs.color == rhs.color &&
        lhs.value == rhs.value &&
        lhs.isWarningEnabled == rhs.isWarningEnabled &&
        lhs.isFlagged == rhs.isFlagged &&
        lhs.isComplete == rhs.isComplete
    }
}

extension KanbanTask: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(projectId)
        hasher.combine(sprintId)
        hasher.combine(title)
        hasher.combine(color)
        hasher.combine(value)
        hasher.combine(isWarningEnabled)
        hasher.combine(isFlagged)
        hasher.combine(isComplete)
    }
}
